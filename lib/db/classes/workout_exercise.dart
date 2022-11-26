import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/workout.dart';

class WorkoutExercise {
  int? id;
  final int workoutId;
  final int exerciseId;
  int? sets;
  double? weight;
  int? reps;
  bool done;

  Workout? workout;
  Exercise? exercise;

  WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    this.sets,
    this.weight,
    this.reps,
    required this.done,
    this.workout,
    this.exercise,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'sets': sets,
        'weight': weight,
        'reps': reps,
        'done': done
      };

  double getWeight() => hasWeight() ? weight! : 0;

  String getRepsAsString() => reps == null ? '0' : reps.toString();

  String getSetsAsString() => sets == null ? '0' : sets.toString();

  String getWeightAsString() {
    if (weight == null) return '0';
    return weight! % 1 == 0
        ? weight!.toStringAsFixed(0)
        : weight!.toStringAsFixed(2);
  }

  String getWeightString({bool showNone = true}) {
    if (weight == null || weight == 0) return showNone ? 'None' : '';
    return '${getWeightAsString()}kg';
  }

  String getNumberedWeightString({bool showNone = true}) {
    if (weight == 0) return showNone ? 'None' : '';
    return '${exercise!.isSingle ? '' : '2 x '}${getWeightString(showNone: showNone)}';
  }

  bool hasWeight() => weight != null && weight! > 0;

  bool thisOrExerciseHasWeight() =>
      hasWeight() || exercise != null && exercise!.hasWeight();
}
