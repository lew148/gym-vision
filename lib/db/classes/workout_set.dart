import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';

import 'exercise.dart';

class WorkoutSet {
  int? id;
  bool done;
  double? weight;
  int? reps;
  bool? single;
  Duration? time;
  double? distance;
  int? calsBurned;

  final int workoutId;
  Workout? workout;

  final int exerciseId;
  Exercise? exercise;

  WorkoutSet({
    this.id,
    this.weight,
    this.reps,
    this.single,
    this.time,
    this.distance,
    this.calsBurned,
    this.done = false,
    required this.workoutId,
    this.workout,
    required this.exerciseId,
    this.exercise,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'single': single,
        'done': done,
        'time': time == null ? '' : time.toString(),
        'distance': distance,
        'calsBurned': calsBurned,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'lastUpdated': DateTime.now().toString()
      };

  void setTime(String? str) => time = str == null ? null : tryParseDuration(str);
  bool isPlaceholder() => !hasReps() && !hasWeight() && !hasTime() && !hasDistance() && !hasCalsBurned();
  bool isCardio() => exercise?.exerciseType == ExerciseType.cardio;

  bool hasWeight() => weight != null && weight != 0;
  double getWeight() => hasWeight() ? weight! : 0;
  String getWeightDisplay() => '${truncateDouble(weight)}kg';

  bool hasReps() => reps != null && reps! > 0;
  String getRepsDisplay() => hasReps() ? '$reps rep${reps == 1 ? '' : 's'}' : 'No Reps';

  bool isSingle() => single ?? false;

  bool hasTime() => time != null && time!.inSeconds > 0;
  String getTimeDisplay() => hasTime() ? time.toString().split('.').first.padLeft(8, "0") : "00.00.00";

  bool hasDistance() => distance != null && distance! > 0;
  String getDistanceDisplay() => '${hasDistance() ? distance!.toStringAsFixed(2) : 0}km';

  bool hasCalsBurned() => calsBurned != null && calsBurned! > 0;
  String getCalsBurnedDisplay() => '${hasCalsBurned() ? calsBurned : 0}kcal';
}
