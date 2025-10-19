import 'package:flutter/material.dart';
import 'package:gymvision/widgets/active_workout_draggable_sheet.dart';
import 'package:gymvision/widgets/components/stateless/logo.dart';

class ScrollBottomPadding extends StatelessWidget {
  const ScrollBottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: ActiveWorkoutDraggableSheet.height,
      child: Center(child: Logo()),
    );
  }
}
