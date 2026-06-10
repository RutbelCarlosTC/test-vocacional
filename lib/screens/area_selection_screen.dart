import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
import '../services/profile_manager.dart';
import '../services/tour_service.dart';
import 'quiz_screen.dart';
import 'result_screen.dart';
import '../widgets/app_drawer.dart';

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final EvaluationService _evalService = EvaluationService();
  final ProfileManager _profileManager = ProfileManager();

  String? _profileId;
  bool _loading = true;

  // Keys para el tour
  final GlobalKey _areaKey = GlobalKey();

  // Progress de cada área
  final Map<EvaluationArea, AreaProgress> _progressMap = {};
  final Map<EvaluationArea, int> _totalsMap = {};

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final profile = await _profileManager.getActiveProfile();
    if (profile == null) return;

    final Map<EvaluationArea, AreaProgress> map = {};
    final Map<EvaluationArea, int> totals = {};

    for (final area in EvaluationArea.values) {
      map[area] = _evalService.getProgress(profile.id, area);
      final questions = await _evalService.loadQuestionsForArea(area);
      totals[area] = questions.length;
    }

    setState(() {
      _profileId = profile.id;
      _progressMap.addAll(map);
      _totalsMap.addAll(totals);
      _loading = false;
    });

    if (!profile.tourAreasShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
    }
  }

  void _startTour() {
    TargetPosition? areaPosition;
    final ctx = _areaKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero);
        final screenWidth = MediaQuery.of(context).size.width;
        areaPosition = TargetPosition(
          Size(screenWidth, box.size.height),
          Offset(0, offset.dy),
        );
      }
    }

    TourService.showTour(
      context,
      targets: [
        TourService.createTarget(
          key: _areaKey,
          targetPosition: areaPosition,
          title: 'Áreas del Test',
          description: 'Aquí verás los diferentes test disponibles. Comenzaremos con el de Preferencias Profesionales.',
        ),
      ],
      onFinish: _markTourAsShown,
      onSkip: _markTourAsShown,
    );
  }

  Future<void> _markTourAsShown() async {
    final profile = await _profileManager.getActiveProfile();
    if (profile != null) {
      final updated = profile.copyWith(tourAreasShown: true);
      await _profileManager.saveProfile(updated);
    }
  }

  Future<void> _startQuiz(EvaluationArea area) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(area: area, profileId: _profileId!),
      ),
    );
    setState(() => _loading = true);
    _loadStatus();
  }

  void _viewResults(EvaluationArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(area: area, profileId: _profileId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Áreas de evaluación')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Selecciona el área que deseas evaluar:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...EvaluationArea.values.map(
                  (area) {
                    final index = EvaluationArea.values.indexOf(area);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _AreaCard(
                        key: index == 0 ? _areaKey : null,
                        area: area,
                        progress: _progressMap[area]!,
                        totalQuestions: _totalsMap[area] ?? 1,
                        onStartQuiz: () => _startQuiz(area),
                        onViewResults: () => _viewResults(area),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Tarjeta de área
// ──────────────────────────────────────────────
class _AreaCard extends StatelessWidget {
  final EvaluationArea area;
  final AreaProgress progress;
  final int totalQuestions;
  final VoidCallback onStartQuiz;
  final VoidCallback onViewResults;

  const _AreaCard({
    super.key,
    required this.area,
    required this.progress,
    required this.totalQuestions,
    required this.onStartQuiz,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttempts = progress.hasCompletedAttempts;
    final canStart = progress.canStartNewAttempt;
    final attemptsLeft = progress.attemptsLeft;
    final totalAttempts = progress.attempts.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + badge de intentos
            Row(
              children: [
                Expanded(
                  child: Text(
                    area.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _AttemptsBadge(
                  totalAttempts: totalAttempts,
                  attemptsLeft: attemptsLeft,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              area.description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            // Borrador en curso
            if (progress.hasDraft) ...[
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final int currentQuestion = progress.draftLastIndex + 1;
                  final double progressValue = totalQuestions > 0
                      ? (currentQuestion / totalQuestions).clamp(0.0, 1.0)
                      : 0.0;
                  final int progressPercent = (progressValue * 100).toInt();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'En progreso (pregunta $currentQuestion)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          backgroundColor: Colors.orange.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.shade500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 14),

            // Botones
            Row(
              children: [
                if (hasAttempts)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewResults,
                      icon: const Icon(Icons.bar_chart, size: 18),
                      label: const Text('Ver resultados'),
                    ),
                  ),
                if (hasAttempts && canStart) const SizedBox(width: 10),
                if (canStart)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onStartQuiz,
                      icon: Icon(
                        progress.hasDraft
                            ? Icons.play_arrow
                            : Icons.assignment_outlined,
                        size: 18,
                      ),
                      label: Text(
                        progress.hasDraft
                            ? 'Continuar'
                            : hasAttempts
                            ? 'Nuevo intento'
                            : 'Iniciar',
                      ),
                    ),
                  ),
                if (!canStart && !hasAttempts)
                  const Text(
                    'Sin intentos disponibles',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Badge de intentos
// ──────────────────────────────────────────────
class _AttemptsBadge extends StatelessWidget {
  final int totalAttempts;
  final int attemptsLeft;

  const _AttemptsBadge({
    required this.totalAttempts,
    required this.attemptsLeft,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String label;

    if (attemptsLeft == 0) {
      bgColor = Colors.red.shade100;
      label = 'Sin intentos';
    } else if (totalAttempts == 0) {
      bgColor = Colors.blue.shade100;
      label = '$attemptsLeft intentos disponibles';
    } else {
      bgColor = Colors.orange.shade100;
      label =
          '$attemptsLeft ${attemptsLeft == 1 ? 'intento' : 'intentos'} restantes';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}