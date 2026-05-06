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
    Color(0xFFE65100), // amber.shade800
  ];

  /// Calcula las coordenadas de cada vértice del polígono regular,
  /// igual que fl_chart: empieza arriba (-π/2) y gira en sentido horario.
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

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox();

    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 320);

          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Gráfico base (SIN datasets de puntos individuales) ──
              RadarChart(
                RadarChartData(
                  dataSets: [
                    // Anillos de escala
                    ...[5.0, 10.0, 15.0].map((val) => RadarDataSet(
                      fillColor: Colors.transparent,
                      borderColor: Colors.grey.withOpacity(0.2),
                      borderWidth: 1,
                      entryRadius: 0,
                      dataEntries: List.generate(
                          scores.length, (_) => RadarEntry(value: val)),
                    )),

                    // Área de resultados principal
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.15),
                      borderColor: Colors.blue.shade700,
                      borderWidth: 2.5,
                      entryRadius: 0, // sin puntos nativos
                      dataEntries: scores
                          .map((s) => RadarEntry(value: s.score.toDouble()))
                          .toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData:
                  const BorderSide(color: Colors.transparent),
                  radarShape: RadarShape.polygon,
                  titlePositionPercentageOffset: 0.22,
                  titleTextStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  getTitle: (index, angle) {
                    if (index >= scores.length) {
                      return const RadarChartTitle(text: '');
                    }
                    final s = scores[index];
                    return RadarChartTitle(
                      text: '${s.label}\n${s.score.toInt()} (${s.level})',
                    );
                  },
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(
                      fontSize: 0, color: Colors.transparent),
                  gridBorderData: const BorderSide(
                      color: Colors.transparent, width: 0),
                ),
              ),

              // ── Puntos de color sobre los vértices del polígono exterior ──
              CustomPaint(
                size: size,
                painter: _VertexDotsPainter(
                  scores: scores,
                  colors: _vertexColors,
                  maxValue: 15.0,
                ),
              ),

              // Máscara central
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

class _VertexDotsPainter extends CustomPainter {
  final List<DimensionScore> scores;
  final List<Color> colors;
  final double maxValue;

  _VertexDotsPainter({
    required this.scores,
    required this.colors,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = scores.length;

    // Radio máximo del radar.
    // fl_chart usa aprox. el 75 % del semi-ancho menor del contenedor.
    final radarRadius = size.shortestSide * 0.75 / 2;

    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (2 * pi / count) * i;
      final ratio = scores[i].score / maxValue;

      // Posición del vértice real (según el score del usuario)
      final vertex = Offset(
        center.dx + radarRadius * ratio * cos(angle),
        center.dy + radarRadius * ratio * sin(angle),
      );

      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(vertex, 6, paint);

      // Borde blanco para destacar el punto
      final border = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(vertex, 6, border);
    }
  }

  @override
  bool shouldRepaint(_VertexDotsPainter old) =>
      old.scores != scores || old.maxValue != maxValue;
}