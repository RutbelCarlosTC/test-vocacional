import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/evaluation_service.dart';

class ResultScreen extends StatelessWidget {
  final EvaluationArea area;
  final String profileId;

  const ResultScreen({
    super.key,
    required this.area,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    final result =
        EvaluationService().getResult(profileId, area);

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el resultado.')),
      );
    }

    final percent = result.percentage;
    final label = _scoreLabel(percent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              area.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Círculo de puntaje
            _ScoreCircle(percent: percent),
            const SizedBox(height: 16),

            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _scoreColor(percent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Puntaje: ${result.totalScore} / ${result.maxPossibleScore}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Resumen de respuestas
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Resumen de respuestas',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ...result.answers.asMap().entries.map((entry) {
              final i = entry.key;
              final answer = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(
                    answer.questionText,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${answer.selectedOption}  (${answer.value} pts)',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(
                  context,
                  (route) => route.isFirst || route.settings.name == '/home',
                ),
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scoreLabel(double percent) {
    if (percent >= 80) return 'Afinidad muy alta';
    if (percent >= 60) return 'Afinidad alta';
    if (percent >= 40) return 'Afinidad media';
    return 'Afinidad baja';
  }

  Color _scoreColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 60) return Colors.blue;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }
}

// ──────────────────────────────────────────────
// Círculo animado de puntaje
// ──────────────────────────────────────────────
class _ScoreCircle extends StatelessWidget {
  final double percent;
  const _ScoreCircle({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80
        ? Colors.green
        : percent >= 60
            ? Colors.blue
            : percent >= 40
                ? Colors.orange
                : Colors.red;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (_, value, __) {
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text(
                    'completado',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
