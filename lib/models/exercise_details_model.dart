import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';

class ExerciseDetailsModel {
  static Future<ExerciseDetails?> getExerciseDetails({
    required String exerciseIdentifier,
    required bool includeRecentUses,
  }) async {
    final List<WorkoutExercise>? wes = includeRecentUses
        ? await WorkoutExerciseModel.getWorkoutExercisesForExercise(
            exerciseIdentifier,
            withSets: true,
            withWorkout: true,
          )
        : null;

    if (wes != null && wes.isNotEmpty) {
      for (var we in wes) {
        we.workout = await WorkoutModel.getWorkout(we.workoutId);
      }
    }

    return ExerciseDetails(
      exerciseIdentifier: exerciseIdentifier,
      max: await WorkoutSetModel.getPR(exerciseIdentifier),
      last: await WorkoutSetModel.getLast(exerciseIdentifier),
      workoutExercises: wes,
    );
  }
}
