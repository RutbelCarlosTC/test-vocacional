import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
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
                      if (widget.area == EvaluationArea.preferencias) ...[
                        _buildMacroPieChart(attempt.dimensionScores),
                        const SizedBox(height: 24),
                        const Text(
                          'Top 3 Carreras Específicas (Micro)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _buildPodium(attempt),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Toca una carrera para ver su descripción',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ] else if (widget.area == EvaluationArea.personalidad) ...[
                        _buildPersonalityRadarChart(attempt.dimensionScores),
                        const SizedBox(height: 32),
                        const Text(
                          'Consejos Personalizados',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildAdviceBoxes(attempt.dimensionScores),
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

  Widget _buildPersonalityRadarChart(List<DimensionScore> scores) {
    if (scores.isEmpty) return const SizedBox();

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: Colors.indigo.withOpacity(0.3),
              borderColor: Colors.indigo,
              entryRadius: 3,
              dataEntries: scores
                  .map((ds) => RadarEntry(value: ds.score.toDouble()))
                  .toList(),
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(color: Colors.grey, width: 1),
          titlePositionPercentageOffset: 0.15,
          titleTextStyle:
              const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          getTitle: (index, angle) {
            if (index >= scores.length) return const RadarChartTitle(text: '');
            return RadarChartTitle(text: scores[index].label);
          },
          tickCount: 3,
          ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.grey),
          gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  Widget _buildAdviceBoxes(List<DimensionScore> scores) {
    final List<Color> boxColors = [
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber.shade800,
    ];

    return Column(
      children: scores.asMap().entries.map((entry) {
        final idx = entry.key;
        final ds = entry.value;
        final advice = _getAdvice(ds.label, ds.level);
        final color = boxColors[idx % boxColors.length];

        if (advice == null) return const SizedBox();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ds.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: color.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ds.level,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                advice,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMacroPieChart(List<DimensionScore> scores) {
    if (scores.isEmpty) return const SizedBox();

    final total = scores.fold<int>(0, (sum, item) => sum + item.score);

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: scores.map((ds) {
                  final double pctValue =
                      total == 0 ? 0 : (ds.score / total) * 100;
                  return PieChartSectionData(
                    color: _getMacroColor(ds.key),
                    value: ds.score.toDouble(),
                    title: '${pctValue.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: scores.map((ds) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getMacroColor(ds.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getMacroLabel(ds.key),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMacroColor(String key) {
    switch (key.toUpperCase()) {
      case 'FIS':
        return Colors.blue.shade600;
      case 'BIO':
        return Colors.green.shade600;
      case 'SOC':
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }

  String _getMacroLabel(String key) {
    switch (key.toUpperCase()) {
      case 'FIS':
        return 'Ciencias Físicas e Ingenierías';
      case 'BIO':
        return 'Ciencias Biológicas y de la Salud';
      case 'SOC':
        return 'Ciencias Sociales y Humanidades';
      default:
        return key;
    }
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

  void _showCareerDescription(String? careerName) {
    if (careerName == null || careerName == 'N/A') return;

    final description =
        _careerDescriptions[careerName] ?? 'Sin descripción disponible.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(careerName, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildPodium(AreaAttempt attempt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2do Lugar
        _PodiumStep(
          careerName: attempt.afinidadSecundaria,
          rank: '2°',
          color: Colors.blue.shade400,
          height: 100,
          onTap: () => _showCareerDescription(attempt.afinidadSecundaria),
        ),
        const SizedBox(width: 8),
        // 1er Lugar
        _PodiumStep(
          careerName: attempt.afinidadPrimaria,
          rank: '1°',
          color: Colors.green.shade500,
          height: 130,
          onTap: () => _showCareerDescription(attempt.afinidadPrimaria),
        ),
        const SizedBox(width: 8),
        // 3er Lugar
        _PodiumStep(
          careerName: attempt.afinidadTerciaria,
          rank: '3°',
          color: Colors.orange.shade400,
          height: 80,
          onTap: () => _showCareerDescription(attempt.afinidadTerciaria),
        ),
      ],
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

class _PodiumStep extends StatelessWidget {
  final String? careerName;
  final String rank;
  final Color color;
  final double height;
  final VoidCallback onTap;

  const _PodiumStep({
    required this.careerName,
    required this.rank,
    required this.color,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = careerName != null && careerName != 'N/A';

    return Expanded(
      child: GestureDetector(
        onTap: hasValue ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasValue)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  careerName!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
