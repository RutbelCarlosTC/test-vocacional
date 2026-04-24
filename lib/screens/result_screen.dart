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

  const _AttemptCard({required this.attempt, required this.isLatest});

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
              '$dateStr  ·  ${attempt.scoreLabel}  ·  ${pct.toStringAsFixed(0)}%',
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
                  // Puntaje
                  Text(
                    'Puntaje: ${attempt.totalScore} / ${attempt.maxPossibleScore}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Afinidades
                  const Text(
                    'Afinidades',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _AfinidadRow(
                      rank: '1°', label: attempt.afinidadPrimaria, color: Colors.green),
                  const SizedBox(height: 4),
                  _AfinidadRow(
                      rank: '2°', label: attempt.afinidadSecundaria, color: Colors.blue),
                  const SizedBox(height: 4),
                  _AfinidadRow(
                      rank: '3°', label: attempt.afinidadTerciaria, color: Colors.orange),

                  const SizedBox(height: 16),

                  // Respuestas detalladas
                  const Text(
                    'Respuestas',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...attempt.answers.asMap().entries.map((e) {
                    final i = e.key;
                    final ans = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ans.questionText,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  '→ ${ans.selectedOption}  (${ans.value > 0 ? '+' : ''}${ans.value})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
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