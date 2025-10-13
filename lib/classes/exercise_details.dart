import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/number_helper.dart';

class ExerciseDetails {
  String exerciseIdentifier;
  WorkoutSet? pr;
  WorkoutSet? last;
  List<WorkoutExercise>? workoutExercises;

  ExerciseDetails({
    required this.exerciseIdentifier,
    this.pr,
    this.last,
    this.workoutExercises,
  });

  String? getPRAsString() => pr == null || pr!.weight! <= 0 ? null : NumberHelper.truncateDouble(pr!.weight);
  
  String? getLastWeightAsString() =>
      last == null || last!.weight! <= 0 ? null : NumberHelper.truncateDouble(last!.weight);

  String? getLastRepsAsString() => last == null || last!.reps! <= 0 ? null : last!.reps.toString();
}
