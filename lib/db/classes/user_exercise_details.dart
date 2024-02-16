import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/globals.dart';

class UserExerciseDetails {
  int exerciseId;
  String? notes;
  WorkoutSet? pr;
  WorkoutSet? last;
  List<WorkoutSet>? recentUses;

  UserExerciseDetails({
    required this.exerciseId,
    this.notes,
    this.pr,
    this.last,
    this.recentUses,
  });

  String? getLastAsString() {
    if (last == null) return null;
    if (last!.weight! <= 0) return null;
    return truncateDouble(last!.weight);
  }

  String? getPRAsString() {
    if (pr == null) return null;
    if (pr!.weight! <= 0) return null;
    return truncateDouble(pr!.weight);
  }
}
