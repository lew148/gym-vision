import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/number_helper.dart';

class WorkoutSummary {
  int totalExercises;
  int totalSets;
  int totalReps;
  int totalCalsBurned;
  String? note;
  WorkoutSet? bestSet;
  Exercise? bestSetExercise;
  double? totalWeightLifted;

  WorkoutSummary({
    this.totalExercises = 0,
    this.totalReps = 0,
    this.totalSets = 0,
    this.totalCalsBurned = 0,
    this.note,
    this.bestSet,
    this.bestSetExercise,
  });

  bool isNote() => note?.isNotEmpty ?? false;

  String getTotalExercisesString() => '$totalExercises exercise${totalExercises == 1 ? '' : 's'}';
  String getTotalSetsString() => '$totalSets set${totalExercises == 1 ? '' : 's'}';
  String getTotalRepsString() => '$totalReps rep${totalReps == 1 ? '' : 's'}';
  String? getTotalWeightLiftedString() =>
      totalWeightLifted == null ? null : '${NumberHelper.doubleToString(totalWeightLifted)}kg total';
}
