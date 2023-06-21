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
        'userId': userId,
        'weight': weight,
        'reps': reps,
        'done': done
      };

  bool hasWeight() => weight != null && weight != 0;

  double getWeight() => hasWeight() ? weight! : 0;

  String getWeightDisplay() =>
      hasWeight() ? '${weight! % 1 == 0 ? weight!.toStringAsFixed(0) : weight!.toStringAsFixed(2)}kg' : '-';
}
