import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
import '../services/profile_manager.dart';
import '../services/tour_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final EvaluationArea area;
  final String profileId;

  const QuizScreen({
    super.key,
    required this.area,
    required this.profileId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final EvaluationService _evalService = EvaluationService();

  List<QuestionModel> _questions = [];
  final List<AnswerRecord> _answers = [];
  int _currentIndex = 0;
  bool _loading = true;
  OptionModel? _selectedOption;

  late AnimationController _animController;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  // Keys para el tour
  final GlobalKey _questionKey = GlobalKey();
  final GlobalKey _optionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _loadQuestions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _evalService.loadQuestionsForArea(widget.area);

    // Recuperar borrador si existe
    final progress = _evalService.getProgress(widget.profileId, widget.area);
    int startIndex = 0;
    if (progress.hasDraft) {
      _answers.addAll(progress.draftAnswers);
      startIndex = progress.draftLastIndex;
      if (startIndex >= questions.length) startIndex = questions.length - 1;

      // Si hay una respuesta guardada para el índice inicial, pre-seleccionarla
      if (startIndex < _answers.length) {
        final savedAns = _answers.firstWhere(
          (a) => a.questionId == questions[startIndex].id,
          orElse: () => AnswerRecord(
              questionId: -1,
              questionText: '',
              selectedOption: '',
              value: 0),
        );
        if (savedAns.questionId != -1) {
          _selectedOption = questions[startIndex].options.firstWhere(
                (o) => o.text == savedAns.selectedOption,
                orElse: () => questions[startIndex].options[0],
              );
        }
      }
    }

    setState(() {
      _questions = questions;
      _currentIndex = startIndex;
      _loading = false;
    });
    _animController.forward(from: 0);

    // Tour: SOLO para Preferencias Profesionales y SOLO la primera vez
    if (widget.area == EvaluationArea.preferencias) {
      final profile = await ProfileManager().getActiveProfile();
      if (profile != null && !profile.tourQuizShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
      }
    }
  }

  void _startTour() {
    // Calculamos la posición real del widget en pantalla para que el foco
    // no se recorte. tutorial_coach_mark a veces no toma bien el ancho
    // completo cuando el key está en un container con padding interno.
    TargetPosition? questionPosition;
    final ctx = _questionKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero);
        final screenWidth = MediaQuery.of(context).size.width;
        // Usamos el ancho completo de pantalla para que no se recorte
        questionPosition = TargetPosition(
          Size(screenWidth, box.size.height),
          Offset(0, offset.dy),
        );
      }
    }

    TourService.showTour(
      context,
      targets: [
        TourService.createTarget(
          key: _questionKey,
          targetPosition: questionPosition,
          title: 'La Pregunta',
          description: 'Lee atentamente el enunciado de cada pregunta.',
        ),
        TourService.createTarget(
          key: _optionsKey,
          title: 'Opciones de Respuesta',
          description: 'Elige la opción que mejor se identifique contigo.',
        ),
      ],
      onFinish: _markTourAsShown,
      onSkip: _markTourAsShown,
    );
  }

  Future<void> _markTourAsShown() async {
    final profile = await ProfileManager().getActiveProfile();
    if (profile != null) {
      final updated = profile.copyWith(tourQuizShown: true);
      await ProfileManager().saveProfile(updated);
    }
  }

  void _selectAnswer(OptionModel option) {
    setState(() => _selectedOption = option);
  }

  Future<void> _handleBack() async {
    if (_currentIndex > 0) {
      if (_selectedOption != null) {
        final question = _questions[_currentIndex];
        final answer = AnswerRecord(
          questionId: question.id,
          questionText: question.question,
          selectedOption: _selectedOption!.text,
          value: _selectedOption!.value,
        );
        final existingIdx =
            _answers.indexWhere((a) => a.questionId == question.id);
        if (existingIdx >= 0) {
          _answers[existingIdx] = answer;
        } else {
          _answers.add(answer);
        }
      }

      setState(() {
        _currentIndex--;
        final prevQuestion = _questions[_currentIndex];
        final prevAns = _answers.firstWhere(
          (a) => a.questionId == prevQuestion.id,
          orElse: () => AnswerRecord(
              questionId: -1,
              questionText: '',
              selectedOption: '',
              value: 0),
        );

        if (prevAns.questionId != -1) {
          _selectedOption = prevQuestion.options.firstWhere(
            (o) => o.text == prevAns.selectedOption,
            orElse: () => prevQuestion.options[0],
          );
        } else {
          _selectedOption = null;
        }
      });
      _animController.forward(from: 0);
    }
  }

  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    final question = _questions[_currentIndex];
    final existingIdx =
        _answers.indexWhere((a) => a.questionId == question.id);
    final answer = AnswerRecord(
      questionId: question.id,
      questionText: question.question,
      selectedOption: _selectedOption!.text,
      value: _selectedOption!.value,
    );

    if (existingIdx >= 0) {
      _answers[existingIdx] = answer;
    } else {
      _answers.add(answer);
    }

    final isLast = _currentIndex == _questions.length - 1;

    if (isLast) {
      final attempt = await _evalService.finalizeAttempt(
        profileId: widget.profileId,
        area: widget.area,
        answers: List.from(_answers),
        questions: _questions,
      );

      if (!mounted) return;

      if (attempt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el intento.')),
        );
        return;
      }

      if (widget.area == EvaluationArea.personalidad && !attempt.isValid) {
        _showInvalidPersonalityDialog();
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            area: widget.area,
            profileId: widget.profileId,
            latestAttempt: attempt,
          ),
        ),
      );
    } else {
      await _evalService.saveDraft(
        profileId: widget.profileId,
        area: widget.area,
        answers: List.from(_answers),
        lastIndex: _currentIndex + 1,
      );

      setState(() {
        _currentIndex++;
        final nextQuestion = _questions[_currentIndex];
        final nextAns = _answers.firstWhere(
          (a) => a.questionId == nextQuestion.id,
          orElse: () => AnswerRecord(
              questionId: -1,
              questionText: '',
              selectedOption: '',
              value: 0),
        );

        if (nextAns.questionId != -1) {
          _selectedOption = nextQuestion.options.firstWhere(
                (o) => o.text == nextAns.selectedOption,
                orElse: () => nextQuestion.options[0],
              );
        } else {
          _selectedOption = null;
        }
      });
      _animController.forward(from: 0);
    }
  }

  void _showInvalidPersonalityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Prueba Invalidada'),
        content: const Text(
            'Se detectaron respuestas inconsistentes o al azar (Ítem de control no superado). '
            'Este intento no se guardará en tu historial. Por favor, realiza el test nuevamente con sinceridad.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    await _evalService.saveDraft(
      profileId: widget.profileId,
      area: widget.area,
      answers: List.from(_answers),
      lastIndex: _currentIndex,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.area.label),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _ProgressHeader(
              progress: progress,
              current: _currentIndex + 1,
              total: _questions.length,
              percent: progressPercent,
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: _QuestionCard(
                    key: ValueKey(_currentIndex),
                    question: question,
                    questionNumber: _currentIndex + 1,
                    onAnswer: _selectAnswer,
                    initialOption: _selectedOption,
                    questionKey: _questionKey,
                    optionsKey: _optionsKey,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: _handleBack,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('ATRÁS'),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedOption == null ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentIndex == _questions.length - 1
                          ? 'FINALIZAR'
                          : 'SIGUIENTE',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final double progress;
  final int current;
  final int total;
  final String percent;

  const _ProgressHeader({
    required this.progress,
    required this.current,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pregunta $current de $total',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final int questionNumber;
  final void Function(OptionModel) onAnswer;
  final OptionModel? initialOption;
  final GlobalKey? questionKey;
  final GlobalKey? optionsKey;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.onAnswer,
    this.initialOption,
    this.questionKey,
    this.optionsKey,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initialOption != null) {
      _selectedIndex = widget.question.options.indexWhere(
        (o) => o.text == widget.initialOption!.text,
      );
      if (_selectedIndex == -1) _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            key: widget.questionKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.question.question,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Selecciona tu respuesta:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            key: widget.optionsKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: widget.question.options.asMap().entries.map((entry) {
                final idx = entry.key;
                final option = entry.value;
                final isSelected = _selectedIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    text: option.text,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedIndex = idx);
                      widget.onAnswer(option);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.white)
            : Icon(Icons.circle_outlined, color: Colors.grey.shade400),
      ),
    );
  }
}