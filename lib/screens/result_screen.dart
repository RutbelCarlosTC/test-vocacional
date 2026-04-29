import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';

/// Puede recibir un [latestAttempt] para resaltarlo (al llegar desde QuizScreen),
/// o usarse sin él para solo consultar historial.
class ResultScreen extends StatefulWidget {
  final EvaluationArea area;
  final String profileId;
  final AreaAttempt? latestAttempt;

  const ResultScreen({
    super.key,
    required this.area,
    required this.profileId,
    this.latestAttempt,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final EvaluationService _evalService = EvaluationService();
  AreaProgress? _progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _progress = _evalService.getProgress(widget.profileId, widget.area);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempts = _progress?.attempts ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados – ${widget.area.label}'),
      ),
      body: attempts.isEmpty
          ? const Center(child: Text('No hay intentos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                // Mostrar el más reciente primero
                final attempt = attempts[attempts.length - 1 - index];
                final isLatest =
                    widget.latestAttempt?.attemptNumber == attempt.attemptNumber;
                return _AttemptCard(
                  attempt: attempt,
                  isLatest: isLatest,
                  area: widget.area,
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Tarjeta expandible de un intento
// ──────────────────────────────────────────────
class _AttemptCard extends StatefulWidget {
  final AreaAttempt attempt;
  final bool isLatest;
  final EvaluationArea area;

  const _AttemptCard({
    required this.attempt,
    required this.isLatest,
    required this.area,
  });

  @override
  State<_AttemptCard> createState() => _AttemptCardState();
}

class _AttemptCardState extends State<_AttemptCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Expandir automáticamente si es el último intento recién finalizado
    _expanded = widget.isLatest;
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    final pct = attempt.percentage;
    final dateStr =
        '${attempt.date.day}/${attempt.date.month}/${attempt.date.year}';

    return Card(
      elevation: widget.isLatest ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isLatest
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          // ── Cabecera ──
          ListTile(
            title: Row(
              children: [
                Text(
                  'Intento ${attempt.attemptNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Reciente',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              dateStr,
              style: const TextStyle(fontSize: 13),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    if (widget.area == EvaluationArea.preferencias &&
                        _isIndiferenciado(attempt.dimensionScores))
                      _buildWarningCard(
                        title: 'Perfil Indiferenciado',
                        message:
                            'Tus puntajes en las tres áreas (FIS, BIO, SOC) son muy similares. '
                            'Esto indica que tus intereses aún no están claramente jerarquizados. '
                            'Se sugiere buscar orientación vocacional personalizada.',
                      ),

                    if (attempt.hasDimensions) ...[
                      // Si es preferencias, mostramos un título específico
                      Text(
                        widget.area == EvaluationArea.preferencias
                            ? 'Perfil de Áreas (Macro)'
                            : 'Resultados por Dimensión',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...attempt.dimensionScores.map((ds) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(ds.label,
                                          style: const TextStyle(fontSize: 13)),
                                    ),
                                    Text(ds.level,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _getLevelColor(ds.level))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: ds.percentage / 100,
                                  minHeight: 4,
                                  backgroundColor: Colors.grey.shade200,
                                  color: _getLevelColor(ds.level),
                                ),
                              ],
                            ),
                          )),

                      // Si es preferencias, también mostramos el Top 3 de Carreras
                      if (widget.area == EvaluationArea.preferencias) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Top 3 Carreras Específicas (Micro)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        _AfinidadRow(
                            rank: '1°',
                            label: attempt.afinidadPrimaria ?? 'N/A',
                            color: Colors.green),
                        const SizedBox(height: 4),
                        _AfinidadRow(
                            rank: '2°',
                            label: attempt.afinidadSecundaria ?? 'N/A',
                            color: Colors.blue),
                        const SizedBox(height: 4),
                        _AfinidadRow(
                            rank: '3°',
                            label: attempt.afinidadTerciaria ?? 'N/A',
                            color: Colors.orange),
                      ],
                    ] else ...[
                      // Afinidades para tests sin dimensiones
                      const Text(
                        'Afinidades',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _AfinidadRow(
                          rank: '1°',
                          label: attempt.afinidadPrimaria ?? 'Sin asignar',
                          color: Colors.green),
                      const SizedBox(height: 4),
                      _AfinidadRow(
                          rank: '2°',
                          label: attempt.afinidadSecundaria ?? 'Sin asignar',
                          color: Colors.blue),
                      const SizedBox(height: 4),
                      _AfinidadRow(
                          rank: '3°',
                          label: attempt.afinidadTerciaria ?? 'Sin asignar',
                          color: Colors.orange),
                    ],
                  ],

                  const SizedBox(height: 16),

                  // Respuestas detalladas
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ],
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Fila de afinidad con rango
// ──────────────────────────────────────────────
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
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            rank,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
