import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/number_helper.dart';

class ExerciseDetails {
  String exerciseIdentifier;
  WorkoutSet? max;
  WorkoutSet? last;
  List<WorkoutExercise>? workoutExercises;

  ExerciseDetails({
    required this.exerciseIdentifier,
    this.max,
    this.last,
    this.workoutExercises,
  });

  MapEntry<String?, String?>? getMaxStrings() => max == null
      ? null
      : MapEntry(
          max!.weight! == 0 ? null : NumberHelper.truncateDouble(max!.weight),
          max!.reps! == 0 ? null : max!.reps.toString(),
        );

  MapEntry<String?, String?>? getLastStrings() => last == null
      ? null
      : MapEntry(
          last!.weight! == 0 ? null : NumberHelper.truncateDouble(last!.weight),
          last!.reps! == 0 ? null : last!.reps.toString(),
        );
}
