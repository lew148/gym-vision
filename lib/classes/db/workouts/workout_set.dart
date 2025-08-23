import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/default_exercises_model.dart';

class WorkoutSet extends DatabaseObject {
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

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'weight': weight,
        'reps': reps,
        'done': done ? 1 : 0,
        'time': time == null ? '' : time.toString(),
        'distance': distance,
        'calsBurned': calsBurned,
        'workoutExerciseId': workoutExerciseId,
      };

  void setTime(String? str) => time = str == null ? null : tryParseDuration(str);

  bool hasWeight() => weight != null && weight != 0;
  double getWeight() => hasWeight() ? weight! : 0;
  String getWeightDisplay() => '${truncateDouble(weight)}kg';

  bool hasReps() => reps != null && reps! > 0;
  String getRepsDisplay() => hasReps() ? '$reps rep${reps == 1 ? '' : 's'}' : 'No Reps';

  bool hasTime() => time != null && time!.inSeconds > 0;
  String getTimeDisplay() => hasTime() ? time.toString().split('.').first.padLeft(8, "0") : "00.00.00";

  bool hasDistance() => distance != null && distance! > 0;
  String getDistanceDisplay() => '${hasDistance() ? distance!.toStringAsFixed(2) : 0}km';

  bool hasCalsBurned() => calsBurned != null && calsBurned! > 0;
  String getCalsBurnedDisplay() => '${hasCalsBurned() ? calsBurned : 0}kcal';

  Exercise? getExercise() {
    if (workoutExercise == null) return null;
    if (workoutExercise!.exercise != null) return workoutExercise!.exercise;
    return DefaultExercisesModel.getExerciseByIdentifier(workoutExercise!.exerciseIdentifier);
  }

  Workout? getWorkout() => workoutExercise?.workout;
}
