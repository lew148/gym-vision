import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gymvision/providers/workout_provider.dart';
import 'package:gymvision/widgets/pages/workout/workout_view_body.dart';

class WorkoutView extends StatelessWidget {
  final int workoutId;
  final bool isActiveWorkout;
  final bool autofocusNotes;
  final int? focusedWorkoutExerciseId;

  const WorkoutView({
    super.key,
    required this.workoutId,
    this.isActiveWorkout = false,
    this.autofocusNotes = false,
    this.focusedWorkoutExerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..loadWorkout(workoutId, focusedWorkoutExerciseId: focusedWorkoutExerciseId),
      child: WorkoutViewBody(autofocusNotes: autofocusNotes),
    );
  }
}
