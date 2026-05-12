import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/evaluation_result.dart';

class PersonalityRadarChart extends StatelessWidget {
  final List<DimensionScore> scores;

  const PersonalityRadarChart({super.key, required this.scores});

  static const List<Color> _vertexColors = [
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Color(0xFFE65100),
  ];

  List<Offset> _computeVertices({
    required Offset center,
    required double radius,
    required int count,
  }) {
    return List.generate(count, (i) {
      final angle = -pi / 2 + (2 * pi / count) * i;
      return Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    });
  }

  String _formatLabel(String label) {
    const breaks = {
      'Aprendizaje Colaborativo': 'Aprendizaje\nColaborativo',
      'Resiliencia y Manejo del Estrés': 'Resiliencia y\nManejo de Estrés',
      'Disciplina Académica': 'Disciplina\nAcadémica',
    };
    return breaks[label] ?? label;
  }

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox();

    return Container(
      height: 340,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 340);

          return Stack(
            alignment: Alignment.center,
            children: [
              RadarChart(
                RadarChartData(
                  dataSets: [
                    ...[5.0, 10.0, 15.0].map((val) => RadarDataSet(
                          fillColor: Colors.transparent,
                          borderColor: Colors.grey.withOpacity(0.2),
                          borderWidth: 1,
                          entryRadius: 0,
                          dataEntries: List.generate(
                              scores.length, (_) => RadarEntry(value: val)),
                        )),
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.15),
                      borderColor: Colors.blue.shade700,
                      borderWidth: 2.5,
                      entryRadius: 0,
                      dataEntries: scores
                          .map((s) => RadarEntry(value: s.score.toDouble()))
                          .toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData:
                      const BorderSide(color: Colors.transparent),
                  radarShape: RadarShape.polygon,
                  titlePositionPercentageOffset: 0.25,
                  titleTextStyle: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  getTitle: (index, angle) {
                    if (index >= scores.length) {
                      return const RadarChartTitle(text: '');
                    }
                    final s = scores[index];
                    final offset = (index == 1 || index == 4) ? 0.10 : 0.15;
                    return RadarChartTitle(
                      text:
                          '${_formatLabel(s.label)}\n${s.score.toInt()} (${s.level})',
                      angle: 0,
                      positionPercentageOffset: offset,
                    );
                  },
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(
                      fontSize: 0, color: Colors.transparent),
                  gridBorderData: const BorderSide(
                      color: Colors.transparent, width: 0),
                ),
              ),

              // Painter unificado: puntos de vértice + etiquetas de escala
              CustomPaint(
                size: size,
                painter: _RadarOverlayPainter(
                  scores: scores,
                  colors: _vertexColors,
                  maxValue: 15.0,
                  scaleLabels: const [5, 10, 15],
                ),
              ),

              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RadarOverlayPainter extends CustomPainter {
  final List<DimensionScore> scores;
  final List<Color> colors;
  final double maxValue;
  final List<int> scaleLabels;

  _RadarOverlayPainter({
    required this.scores,
    required this.colors,
    required this.maxValue,
    required this.scaleLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = scores.length;
    final radarRadius = size.shortestSide * 0.75 / 2;

    // ── 1. Etiquetas de escala en el eje superior (punta del pentágono) ──
    final angleTop = -pi / 2; // Ángulo de la punta (vértice 0)
    
    for (final label in scaleLabels) {
      final ratio = label / maxValue;
      final ringRadius = radarRadius * ratio;

      // Posición en el eje vertical
      final point = Offset(
        center.dx + ringRadius * cos(angleTop),
        center.dy + ringRadius * sin(angleTop),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$label',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700, // Un gris más oscuro para mejor lectura
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Centradas horizontalmente y posicionadas con un margen superior mayor sobre cada nivel (5, 10, 15)
      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          point.dy - 10, // Elevamos los números un poco más para que queden más despejados hacia la punta
        ),
      );
    }

    // ── 2. Puntos de color sobre los vértices ──
    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (2 * pi / count) * i;
      final ratio = scores[i].score / maxValue;

      final vertex = Offset(
        center.dx + radarRadius * ratio * cos(angle),
        center.dy + radarRadius * ratio * sin(angle),
      );

      final color = colors[i % colors.length];

      canvas.drawCircle(vertex, 6, Paint()..color = color);
      canvas.drawCircle(
        vertex,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarOverlayPainter old) =>
      old.scores != scores || old.maxValue != maxValue;
}