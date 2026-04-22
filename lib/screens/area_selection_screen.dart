import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
import '../services/profile_manager.dart';
import 'quiz_screen.dart';

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

  // Estado de cada área
  final Map<EvaluationArea, _AreaStatus> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final profile = await _profileManager.getActiveProfile();
    if (profile == null) return;

    final Map<EvaluationArea, _AreaStatus> map = {};
    for (final area in EvaluationArea.values) {
      final result = _evalService.getResult(profile.id, area);
      map[area] = _AreaStatus(
        completed: result?.completed ?? false,
        answeredCount: result?.lastAnsweredIndex ?? 0,
        totalQuestions: 0, // se calcula tras cargar
      );
    }

    // Carga preguntas para saber el total de cada área
    for (final area in EvaluationArea.values) {
      final questions = await _evalService.loadQuestionsForArea(area);
      map[area] = _AreaStatus(
        completed: map[area]!.completed,
        answeredCount: map[area]!.answeredCount,
        totalQuestions: questions.length,
      );
    }

    setState(() {
      _profileId = profile.id;
      _statusMap.addAll(map);
      _loading = false;
    });
  }

  Future<void> _openArea(EvaluationArea area) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(area: area, profileId: _profileId!),
      ),
    );
    // Recargar estado al volver
    setState(() => _loading = true);
    _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir área de evaluación'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona el área que deseas evaluar:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ...EvaluationArea.values.map(
                    (area) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _AreaCard(
                        area: area,
                        status: _statusMap[area]!,
                        onTap: () => _openArea(area),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Estado de un área
// ──────────────────────────────────────────────
class _AreaStatus {
  final bool completed;
  final int answeredCount;
  final int totalQuestions;

  _AreaStatus({
    required this.completed,
    required this.answeredCount,
    required this.totalQuestions,
  });

  double get progress =>
      totalQuestions == 0 ? 0 : answeredCount / totalQuestions;
}

// ──────────────────────────────────────────────
// Tarjeta de área
// ──────────────────────────────────────────────
class _AreaCard extends StatelessWidget {
  final EvaluationArea area;
  final _AreaStatus status;
  final VoidCallback onTap;

  const _AreaCard({
    required this.area,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final completed = status.completed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      area.label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Finalizado',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  else if (status.answeredCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'En progreso',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                area.description,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completed ? 1.0 : status.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? Colors.green : color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                completed
                    ? '100% completado'
                    : status.answeredCount == 0
                        ? '${status.totalQuestions} preguntas'
                        : '${status.answeredCount} / ${status.totalQuestions} preguntas',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
