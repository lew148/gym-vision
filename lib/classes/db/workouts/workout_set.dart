import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';

class WorkoutSet extends DBO {
  int workoutExerciseId;
  double? weight;
  int? reps;
  Duration? time;
  double? distance;
  int? calsBurned;
  bool done;

  // non-db props
  WorkoutExercise? workoutExercise;

  WorkoutSet({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.workoutExerciseId,
    this.done = false,
    this.weight,
    this.reps,
    this.time,
    this.distance,
    this.calsBurned,
    this.workoutExercise,
  });

  Exercise? getExercise() {
    if (workoutExercise == null) return null;
    if (workoutExercise!.exercise != null) return workoutExercise!.exercise;
    return DefaultExercisesModel.getExerciseByIdentifier(workoutExercise!.exerciseIdentifier);
  }

  Workout? getWorkout() => workoutExercise?.workout;
}
