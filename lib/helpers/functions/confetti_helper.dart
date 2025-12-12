import 'package:flutter/widgets.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

class ConfettiHelper {
  static void straightUp(BuildContext context) => Confetti.launch(
        context,
        options: const ConfettiOptions(
          particleCount: 200,
          spread: 70,
          y: 0.8,
        ),
      );

  static void bothSidesInward(BuildContext context) {
    // left
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 200,
        spread: 70,
        x: -0.1,
        y: 0.8,
        angle: 67.5,
      ),
    );

    // right
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 200,
        spread: 70,
        x: 1.1,
        y: 0.8,
        angle: 112.5,
      ),
    );
  }
}
