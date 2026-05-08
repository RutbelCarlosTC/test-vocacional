import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/evaluation_result.dart';

class MacroPieChart extends StatelessWidget {
  final List<DimensionScore> scores;

  const MacroPieChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
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
                sectionsSpace: 3,
                centerSpaceRadius: 44,
                sections: scores.map((ds) {
                  final double pctValue =
                      total == 0 ? 0 : (ds.score / total) * 100;
                  final color = _getMacroColor(ds.key);
                  return PieChartSectionData(
                    color: color,
                    value: ds.score.toDouble(),
                    title: '${pctValue.toStringAsFixed(0)}%',
                    radius: 54,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.6),
                      width: 2,
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
        return const Color(0xFF4A90D9); // azul medio, claro y limpio
      case 'BIO':
        return const Color(0xFF4CAF82); // verde esmeralda suave
      case 'SOC':
        return const Color(0xFFE07B54); // terracota cálido
      default:
        return const Color(0xFFB0BEC5);
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
}