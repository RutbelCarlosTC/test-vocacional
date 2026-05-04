import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';

class AttemptDetailScreen extends StatelessWidget {
  final AreaAttempt attempt;
  final EvaluationArea area;

  const AttemptDetailScreen({
    super.key,
    required this.attempt,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final pct = attempt.percentage;
    final dateStr =
        '${attempt.date.day}/${attempt.date.month}/${attempt.date.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Intento ${attempt.attemptNumber} - ${area.label}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de fecha
            Text(
              'Fecha de evaluación: $dateStr',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Si la prueba no es válida (Protocolo del Ítem 16)
            if (!attempt.isValid) ...[
              _buildWarningCard(
                title: 'PRUEBA INVALIDADA',
                message:
                    'Se detectaron respuestas inconsistentes o al azar. '
                    'Te recomendamos realizar el test nuevamente con sinceridad.',
              ),
            ] else ...[
              // --- Diagnóstico Especial: Perfil Indiferenciado (Preferencias) ---
              if (area == EvaluationArea.preferencias &&
                  _isIndiferenciado(attempt.dimensionScores))
                _buildWarningCard(
                  title: 'Perfil Indiferenciado',
                  message:
                      'Tus puntajes en las tres áreas (FIS, BIO, SOC) son muy similares. '
                      'Esto indica que tus intereses aún no están claramente jerarquizados. '
                      'Se sugiere buscar orientación vocacional personalizada.',
                ),

              if (attempt.hasDimensions) ...[
                Text(
                  area == EvaluationArea.preferencias
                      ? 'Perfil de Áreas (Macro)'
                      : 'Resultados por Dimensión',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...attempt.dimensionScores.map((ds) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(ds.label,
                                    style: const TextStyle(fontSize: 14)),
                              ),
                              Text(ds.level,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _getLevelColor(ds.level))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ds.percentage / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              color: _getLevelColor(ds.level),
                            ),
                          ),
                        ],
                      ),
                    )),

                if (area == EvaluationArea.preferencias) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Top 3 Carreras Específicas (Micro)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _AfinidadRow(
                      rank: '1°',
                      label: attempt.afinidadPrimaria ?? 'N/A',
                      color: Colors.green),
                  const SizedBox(height: 8),
                  _AfinidadRow(
                      rank: '2°',
                      label: attempt.afinidadSecundaria ?? 'N/A',
                      color: Colors.blue),
                  const SizedBox(height: 8),
                  _AfinidadRow(
                      rank: '3°',
                      label: attempt.afinidadTerciaria ?? 'N/A',
                      color: Colors.orange),
                ],
              ] else ...[
                const Text(
                  'Afinidades',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _AfinidadRow(
                    rank: '1°',
                    label: attempt.afinidadPrimaria ?? 'Sin asignar',
                    color: Colors.green),
                const SizedBox(height: 8),
                _AfinidadRow(
                    rank: '2°',
                    label: attempt.afinidadSecundaria ?? 'Sin asignar',
                    color: Colors.blue),
                const SizedBox(height: 8),
                _AfinidadRow(
                    rank: '3°',
                    label: attempt.afinidadTerciaria ?? 'Sin asignar',
                    color: Colors.orange),
              ],
            ],

            const SizedBox(height: 32),

            // Respuestas detalladas
            const Text(
              'Respuestas detalladas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...attempt.answers.asMap().entries.map((e) {
              final i = e.key;
              final ans = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ans.questionText,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            '→ ${ans.selectedOption}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return Colors.red;
      case 'medio':
        return Colors.orange;
      case 'alto':
        return Colors.green;
      case 'muy alto':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  bool _isIndiferenciado(List<DimensionScore> scores) {
    if (scores.length < 3) return false;
    final values = scores.map((s) => s.score).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    return (max - min) < 4;
  }

  Widget _buildWarningCard({required String title, required String message}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AfinidadRow extends StatelessWidget {
  final String rank;
  final String label;
  final Color color;

  const _AfinidadRow({
    required this.rank,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            rank,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
