import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/exercises/exercises.dart';
import 'package:gymvision/static_data/enums.dart';

class AddExercisesToWorkout extends StatefulWidget {
  final int workoutId;
  final List<Category> setCategories;

  const AddExercisesToWorkout({
    super.key,
    required this.workoutId,
    required this.setCategories,
  });

  @override
  State<AddExercisesToWorkout> createState() => _AddExercisesToWorkoutState();
}

class _AddExercisesToWorkoutState extends State<AddExercisesToWorkout> {
  void onExerciseAdd(String exerciseIdentifier) async {
    try {
      await WorkoutExerciseModel.insertWorkoutExercise(
        WorkoutExercise(
          workoutId: widget.workoutId,
          exerciseIdentifier: exerciseIdentifier,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add set(s) to workout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      ignoreDefaults: true,
      body: Exercises(
        filterCategories: widget.setCategories,
        onAddTap: onExerciseAdd,
      ),
    );
  }
}
