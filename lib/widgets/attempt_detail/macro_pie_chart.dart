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
}
