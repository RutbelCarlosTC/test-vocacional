import 'package:flutter/material.dart';

class AfinidadRow extends StatelessWidget {
  final String rank;
  final String label;
  final Color color;

  const AfinidadRow({
    super.key,
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
