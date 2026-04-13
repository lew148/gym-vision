import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/classes/set_info.dart';
import 'package:gymvision/models/default_exercises_model.dart';

class WorkoutSet extends DBO {
  int workoutExerciseId;
  bool done;

  double? weight;
  int? reps;
  double? addedWeight;
  double? assistedWeight;

  Duration? time;
  double? distance;
  int? calsBurned;

  // non-db props
  WorkoutExercise? workoutExercise;
  SetInfo? info;

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
    this.addedWeight,
    this.assistedWeight,
  });

  Map toMap() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'time': time?.toString(),
        'distance': distance,
        'calsBurned': calsBurned,
        'done': done ? 1 : 0,
      };

  Exercise? getExercise() {
    if (workoutExercise == null) return null;
    if (workoutExercise!.exercise != null) return workoutExercise!.exercise;
    return DefaultExercisesModel.getExerciseByIdentifier(workoutExercise!.exerciseIdentifier);
  }

  Workout? getWorkout() => workoutExercise?.workout;

  bool isGreaterThan(WorkoutSet set) {
    final thisWeight = weight ?? 0;
    final thisReps = reps ?? 0;
    final compareWeight = set.weight ?? 0;
    final compareReps = set.reps ?? 0;

    if (thisWeight > compareWeight) return true; // greater weight
    if (thisWeight < compareWeight) return false; // smaller weight

    // same weight
    return thisReps > compareReps;
  }

  void setInfo({WorkoutSet? pr, WorkoutSet? first}) {
    if (!done) return;

    info = SetInfo(isFirstUse: id == first?.id);

    if (pr != null) {
      if (id == pr.id) info!.isPR = true;
      if (weight == pr.weight && reps == pr.reps) info!.isPRMatch = true;
    }
  }
}
