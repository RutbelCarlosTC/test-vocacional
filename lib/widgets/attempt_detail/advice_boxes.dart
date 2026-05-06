import 'package:flutter/material.dart';
import '../../models/evaluation_result.dart';

class AdviceBoxes extends StatelessWidget {
  final List<DimensionScore> scores;
  final Map<String, dynamic> personalityAdvice;

  const AdviceBoxes({
    super.key,
    required this.scores,
    required this.personalityAdvice,
  });

  String? _getAdvice(String dimension, String level) {
    if (personalityAdvice.containsKey(dimension)) {
      return personalityAdvice[dimension][level];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
}
