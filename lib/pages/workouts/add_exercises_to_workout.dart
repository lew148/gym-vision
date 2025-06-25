import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/exercises/exercises.dart';

class AddExercisesToWorkout extends StatefulWidget {
  final int workoutId;

  const AddExercisesToWorkout({
    super.key,
    required this.workoutId,
  });

  @override
  State<AddExercisesToWorkout> createState() => _AddExercisesToWorkoutState();
}

class _AddExercisesToWorkoutState extends State<AddExercisesToWorkout> {
  late Future<Workout?> workout = WorkoutModel.getWorkout(
    workoutId: widget.workoutId,
    includeCategories: true,
    includeWorkoutExercises: true,
  );

  void onExerciseAdd(String exerciseIdentifier) async {
    try {
      await WorkoutExerciseModel.insertWorkoutExercise(
        WorkoutExercise(
          workoutId: widget.workoutId,
          exerciseIdentifier: exerciseIdentifier,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add set(s) to workout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      ignoreDefaults: true,
      body: FutureBuilder(
          future: workout,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Failed to load."));
            }

            return Exercises(
              filterCategories: snapshot.data!.getCategories(),
              excludedExerciseIdentifiers:
                  snapshot.data!.getWorkoutExercises().map((we) => we.exerciseIdentifier).toList(),
              onAddTap: onExerciseAdd,
            );
          }),
    );
  }
}
