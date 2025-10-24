import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';

class ExerciseDetailsModel {
  static Future<ExerciseDetails?> getExerciseDetails({
    required String exerciseIdentifier,
    required bool includeRecentUses,
  }) async {
    return ExerciseDetails(
      exerciseIdentifier: exerciseIdentifier,
      max: await getPr(exerciseIdentifier),
      last: await getLast(exerciseIdentifier),
      workoutExercises: includeRecentUses
          ? await WorkoutExerciseModel.getWorkoutExercisesForExercise(
              exerciseIdentifier,
              withSets: true,
              withWorkout: true,
            )
          : null,
    );
  }

  /*
    - for the getSetsForExercise, getPr and getLast:
    - only used in ExerciseDetailsModel
    - used by recent uses widget in exercise screen, so requires WE and Workout loaded (expensive)
    - have made a ticket to rework this
  */
  static Future<List<WorkoutSet>> getSetsForExerciseWithWorkoutExerciseAndWorkout(String exerciseIdentifier) async {
    final List<WorkoutSet> sets = [];
    final workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesForExercise(
      exerciseIdentifier,
      withSets: true,
      withWorkout: true,
    );

    for (final we in workoutExercises) {
      we.workout = await WorkoutModel.getWorkout(we.workoutId);
      sets.addAll((await WorkoutSetModel.getSetsForWorkoutExercise(we.id!)).map((s) {
        s.workoutExercise = we;
        return s;
      }));
    }

    return sets;
  }

  static Future<WorkoutSet?> getPr(String exerciseIdentifier) async {
    final allSets = await getSetsForExerciseWithWorkoutExerciseAndWorkout(exerciseIdentifier);
    allSets.removeWhere((s) => !s.done);
    allSets.sort((a, b) => (b.weight ?? 0).compareTo((a.weight ?? 0)));
    if (allSets.isEmpty) return null;

    final heaviestWeight = allSets.first.weight;
    allSets.removeWhere((s) => s.weight != heaviestWeight);

    allSets.sort((a, b) => b.reps!.compareTo(a.reps!));
    final mostReps = allSets.first.reps;
    allSets.removeWhere((s) => s.reps != mostReps);

    allSets.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return allSets.firstOrNull;
  }

  static Future<WorkoutSet?> getLast(String exerciseIdentifier) async {
    final allSets = await getSetsForExerciseWithWorkoutExerciseAndWorkout(exerciseIdentifier);
    allSets.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return allSets.firstOrNull;
  }
}
