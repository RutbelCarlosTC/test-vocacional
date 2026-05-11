import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TourService {
  static void showTour(
    BuildContext context, {
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      textSkip: "SALTAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: onFinish,
      onSkip: () {
        onSkip?.call();
        return true;
      },
      onClickTarget: (target) {},
    ).show(context: context);
  }

  static TargetFocus createTarget({
    required GlobalKey key,
    TargetPosition? targetPosition, // <-- nuevo parámetro opcional
    required String title,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
  }) {
    return TargetFocus(
      identify: key.toString(),
      keyTarget: targetPosition == null ? key : null, // si hay posición manual, no usar key
      targetPosition: targetPosition,                 // posición manual toma precedencia
      alignSkip: Alignment.topRight,
      shape: shape,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}