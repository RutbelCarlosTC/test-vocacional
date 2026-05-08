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
    return Column(
      children: [
        // Etiquetas de carrera encima del podio
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CareerLabel(name: attempt.afinidadSecundaria, color: _silver),
            const SizedBox(width: 8),
            _CareerLabel(name: attempt.afinidadPrimaria, color: _gold),
            const SizedBox(width: 8),
            _CareerLabel(name: attempt.afinidadTerciaria, color: _bronze),
          ],
        ),
        const SizedBox(height: 12),

        // Bloques del podio
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _PodiumBlock(
              rank: '2°',
              height: 90,
              color: _silver,
              onTap: () => onCareerTap(attempt.afinidadSecundaria),
              hasValue: _hasValue(attempt.afinidadSecundaria),
            ),
            const SizedBox(width: 8),
            _PodiumBlock(
              rank: '1°',
              height: 130,
              color: _gold,
              onTap: () => onCareerTap(attempt.afinidadPrimaria),
              hasValue: _hasValue(attempt.afinidadPrimaria),
            ),
            const SizedBox(width: 8),
            _PodiumBlock(
              rank: '3°',
              height: 65,
              color: _bronze,
              onTap: () => onCareerTap(attempt.afinidadTerciaria),
              hasValue: _hasValue(attempt.afinidadTerciaria),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasValue(String? v) => v != null && v != 'N/A';

  static const _gold   = Color(0xFFFFD700);
  static const _silver = Color(0xFFB0BEC5);
  static const _bronze = Color(0xFFCD7F32);
}

// ── Etiqueta de carrera ──────────────────────────────────────────────────────

class _CareerLabel extends StatelessWidget {
  final String? name;
  final Color color;

  const _CareerLabel({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool hasValue = name != null && name != 'N/A';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Text(
          hasValue ? name! : '—',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: hasValue ? Colors.black87 : Colors.black38,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

// ── Medalla ──────────────────────────────────────────────────────────────────

class _Medal extends StatelessWidget {
  final String emoji;
  const _Medal({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ── Bloque del podio ─────────────────────────────────────────────────────────

class _PodiumBlock extends StatelessWidget {
  final String rank;
  final double height;
  final Color color;
  final VoidCallback onTap;
  final bool hasValue;

  const _PodiumBlock({
    required this.rank,
    required this.height,
    required this.color,
    required this.onTap,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: hasValue ? onTap : null,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.85), color],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
              if (hasValue) ...[
                const SizedBox(height: 4),
                Icon(Icons.touch_app_rounded,
                    color: Colors.white.withOpacity(0.7), size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}