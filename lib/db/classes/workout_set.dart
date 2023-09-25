import 'package:gymvision/db/classes/workout.dart';

import 'exercise.dart';

class WorkoutSet {
  int? id;
  int? userId;
  double? weight;
  int? reps;
  bool done;

  final int workoutId;
  Workout? workout;

  final int exerciseId;
  Exercise? exercise;

  WorkoutSet({
    this.id,
    this.userId,
    this.weight,
    this.reps,
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
        'done': done,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'lastUpdated': DateTime.now().toString()
      };

  bool hasWeight() => weight != null && weight != 0;

  double getWeight() => hasWeight() ? weight! : 0;

  String getWeightDisplay() =>
      hasWeight() ? '${weight! % 1 == 0 ? weight!.toStringAsFixed(0) : weight!.toStringAsFixed(2)}kg' : '-';

  String? getWeightAsString() {
    if (!hasWeight()) return null;
    return weight! % 1 == 0 ? weight!.toStringAsFixed(0) : weight!.toStringAsFixed(2);
  }

  String? getWeightString({bool showNone = true}) {
    if (!hasWeight()) return showNone ? 'None' : null;
    return '${getWeightAsString()}kg';
  }

  String? getNumberedWeightString({bool showNone = true}) {
    if (!hasWeight()) return showNone ? 'None' : null;
    return '${exercise!.isDouble ? '2 x ' : ''}${getWeightString(showNone: showNone)}';
  }

  bool hasReps() => reps != null && reps! > 0;

  String getRepsAsString() => !hasReps() ? '0' : reps.toString();

  String getRepsDisplayString() => hasReps() ? '$reps rep${reps == 1 ? '' : 's'}' : 'No Reps';
}
