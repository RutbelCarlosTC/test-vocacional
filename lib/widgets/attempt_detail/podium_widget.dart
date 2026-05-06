import 'package:flutter/material.dart';
import '../../models/evaluation_result.dart';

class PodiumWidget extends StatelessWidget {
  final AreaAttempt attempt;
  final Function(String?) onCareerTap;

  const PodiumWidget({
    super.key,
    required this.attempt,
    required this.onCareerTap,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: () => onCareerTap(attempt.afinidadSecundaria),
        ),
        const SizedBox(width: 8),
        // 1er Lugar
        _PodiumStep(
          careerName: attempt.afinidadPrimaria,
          rank: '1°',
          color: Colors.green.shade500,
          height: 130,
          onTap: () => onCareerTap(attempt.afinidadPrimaria),
        ),
        const SizedBox(width: 8),
        // 3er Lugar
        _PodiumStep(
          careerName: attempt.afinidadTerciaria,
          rank: '3°',
          color: Colors.orange.shade400,
          height: 80,
          onTap: () => onCareerTap(attempt.afinidadTerciaria),
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
