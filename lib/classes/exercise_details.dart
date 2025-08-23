import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/number_helper.dart';

class ExerciseDetails {
  String exerciseIdentifier;
  String? notes;
  WorkoutSet? pr;
  WorkoutSet? last;
  List<WorkoutSet>? recentUses;

  ExerciseDetails({
    required this.exerciseIdentifier,
    this.notes,
    this.pr,
    this.last,
    this.recentUses,
  });

  String? getPRAsString() {
    if (pr == null) return null;
    if (pr!.weight! <= 0) return null;
    return NumberHelper.truncateDouble(pr!.weight);
  }

  String? getLastAsString() {
    if (last == null) return null;
    if (last!.weight! <= 0) return null;
    return NumberHelper.truncateDouble(last!.weight);
  }
}
