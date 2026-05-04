import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';

class AttemptDetailScreen extends StatefulWidget {
  final AreaAttempt attempt;
  final EvaluationArea area;

  const AttemptDetailScreen({
    super.key,
    required this.attempt,
    required this.area,
  });

  @override
  State<AttemptDetailScreen> createState() => _AttemptDetailScreenState();
}

class _AttemptDetailScreenState extends State<AttemptDetailScreen> {
  Map<String, String> _careerDescriptions = {};
  Map<String, dynamic> _personalityAdvice = {};
  bool _loadingData = false;

  @override
  void initState() {
    super.initState();
    if (widget.area == EvaluationArea.preferencias) {
      _loadCareerDescriptions();
    } else if (widget.area == EvaluationArea.personalidad) {
      _loadPersonalityAdvice();
    }
  }

  Future<void> _loadCareerDescriptions() async {
    setState(() => _loadingData = true);
    try {
      final String response =
          await rootBundle.loadString('assets/data/carreras.json');
      final List<dynamic> data = json.decode(response);
      final Map<String, String> descriptions = {};
      for (var item in data) {
        descriptions[item['carrera']] = item['descripcion'];
      }
      setState(() {
        _careerDescriptions = descriptions;
        _loadingData = false;
      });
    } catch (e) {
      debugPrint('Error cargando descripciones de carreras: $e');
      setState(() => _loadingData = false);
    }
  }

  Future<void> _loadPersonalityAdvice() async {
    setState(() => _loadingData = true);
    try {
      final String response =
          await rootBundle.loadString('assets/data/consejos_personalidad.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        _personalityAdvice = data;
        _loadingData = false;
      });
    } catch (e) {
      debugPrint('Error cargando consejos de personalidad: $e');
      setState(() => _loadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    final dateStr =
        '${attempt.date.day}/${attempt.date.month}/${attempt.date.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Intento ${attempt.attemptNumber} - ${widget.area.label}'),
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de fecha
                  Text(
                    'Fecha de evaluación: $dateStr',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
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
                      Text(
                        widget.area == EvaluationArea.preferencias
                            ? 'Perfil de Áreas (Macro)'
                            : 'Resultados por Dimensión',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ...attempt.dimensionScores.map((ds) {
                        final advice = widget.area == EvaluationArea.personalidad
                            ? _getAdvice(ds.label, ds.level)
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(ds.label,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
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
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  color: _getLevelColor(ds.level),
                                ),
                              ),
                              if (advice != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.blue.shade100),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.lightbulb_outline,
                                          size: 20,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          advice,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue.shade900,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      if (widget.area == EvaluationArea.preferencias) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Top 3 Carreras Específicas (Micro)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        _buildCareerInfo(
                            attempt.afinidadPrimaria, '1°', Colors.green),
                        const SizedBox(height: 12),
                        _buildCareerInfo(
                            attempt.afinidadSecundaria, '2°', Colors.blue),
                        const SizedBox(height: 12),
                        _buildCareerInfo(
                            attempt.afinidadTerciaria, '3°', Colors.orange),
                      ],
                    ] else ...[
                      const Text(
                        'Afinidades',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                  //const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  String? _getAdvice(String dimension, String level) {
    if (_personalityAdvice.containsKey(dimension)) {
      return _personalityAdvice[dimension][level];
    }
    return null;
  }

  Widget _buildCareerInfo(String? careerName, String rank, Color color) {
    if (careerName == null || careerName == 'N/A') return const SizedBox();

    final description =
        _careerDescriptions[careerName] ?? 'Sin descripción disponible.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  careerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
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
