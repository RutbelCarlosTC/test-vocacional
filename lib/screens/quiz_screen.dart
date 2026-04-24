import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
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
    }

    setState(() {
      _questions = questions;
      _currentIndex = startIndex;
      _loading = false;
    });
    _animController.forward(from: 0);
  }

  void _selectAnswer(OptionModel option) {
    setState(() => _selectedOption = option);
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
      // Finalizar intento y guardar
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
      // Guardar borrador
      await _evalService.saveDraft(
        profileId: widget.profileId,
        area: widget.area,
        answers: List.from(_answers),
        lastIndex: _currentIndex + 1,
      );

      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
      _animController.forward(from: 0);
    }
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
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedOption == null ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
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
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Header con barra de progreso
// ──────────────────────────────────────────────
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

// ──────────────────────────────────────────────
// Tarjeta de pregunta con opciones
// ──────────────────────────────────────────────
class _QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final int questionNumber;
  final void Function(OptionModel) onAnswer;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.onAnswer,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              widget.question.question,
              style: const TextStyle(fontSize: 17, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selecciona tu respuesta:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...widget.question.options.asMap().entries.map((entry) {
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
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Tile de opción
// ──────────────────────────────────────────────
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