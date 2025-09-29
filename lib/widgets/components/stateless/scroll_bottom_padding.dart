import 'package:flutter/material.dart';
import 'package:gymvision/widgets/active_workout_bar.dart';
import 'package:gymvision/widgets/components/stateless/logo.dart';

class ScrollBottomPadding extends StatelessWidget {
  const ScrollBottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: ActiveWorkoutBar.height - 5,
      child: Center(child: Logo()),
    );
  }
}
