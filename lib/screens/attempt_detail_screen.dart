import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../widgets/attempt_detail/warning_card.dart';
import '../widgets/attempt_detail/macro_pie_chart.dart';
import '../widgets/attempt_detail/personality_radar_chart.dart';
import '../widgets/attempt_detail/advice_boxes.dart';
import '../widgets/attempt_detail/podium_widget.dart';
import '../widgets/attempt_detail/afinidad_row.dart';

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
                    const WarningCard(
                      title: 'PRUEBA INVALIDADA',
                      message:
                          'Se detectaron respuestas inconsistentes o al azar. '
                          'Te recomendamos realizar el test nuevamente con sinceridad.',
                    ),
                  ] else ...[
                    // --- Diagnóstico Especial: Perfil Indiferenciado (Preferencias) ---
                    if (widget.area == EvaluationArea.preferencias &&
                        _isIndiferenciado(attempt.dimensionScores))
                      const WarningCard(
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
                      if (widget.area == EvaluationArea.preferencias) ...[
                        MacroPieChart(scores: attempt.dimensionScores),
                        const SizedBox(height: 24),
                        const Text(
                          'Top 3 Carreras Específicas (Micro)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        PodiumWidget(
                          attempt: attempt,
                          onCareerTap: _showCareerDescription,
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Toca una carrera para ver su descripción',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ] else if (widget.area == EvaluationArea.personalidad) ...[
                        Builder(builder: (context) {
                          // Forzamos el orden para que coincida con lo solicitado (incluso para intentos previos)
                          final sortedScores = List<DimensionScore>.from(attempt.dimensionScores);
                          const order = [
                            'Resiliencia y Manejo del Estrés',
                            'Disciplina Académica',
                            'Curiosidad Intelectual',
                            'Liderazgo y Sociabilidad',
                            'Aprendizaje Colaborativo',
                          ];
                          sortedScores.sort((a, b) {
                            int idxA = order.indexOf(a.label);
                            int idxB = order.indexOf(b.label);
                            // Si alguna no está en la lista (por si acaso), la mandamos al final
                            if (idxA == -1) idxA = 99;
                            if (idxB == -1) idxB = 99;
                            return idxA.compareTo(idxB);
                          });

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PersonalityRadarChart(scores: sortedScores),
                              const SizedBox(height: 32),
                              const Text(
                                'Consejos Personalizados',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              AdviceBoxes(
                                scores: sortedScores,
                                personalityAdvice: _personalityAdvice,
                              ),
                            ],
                          );
                        }),
                      ] else
                        ...attempt.dimensionScores.map((ds) {
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
                              ],
                            ),
                          );
                        }),
                    ] else ...[
                      const Text(
                        'Afinidades',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      AfinidadRow(
                          rank: '1°',
                          label: attempt.afinidadPrimaria ?? 'Sin asignar',
                          color: Colors.green),
                      const SizedBox(height: 8),
                      AfinidadRow(
                          rank: '2°',
                          label: attempt.afinidadSecundaria ?? 'Sin asignar',
                          color: Colors.blue),
                      const SizedBox(height: 8),
                      AfinidadRow(
                          rank: '3°',
                          label: attempt.afinidadTerciaria ?? 'Sin asignar',
                          color: Colors.orange),
                    ],
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showCareerDescription(String? careerName) {
    if (careerName == null || careerName == 'N/A') return;

    final description =
        _careerDescriptions[careerName] ?? 'Sin descripción disponible.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(careerName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(description, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
}
