import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/globals.dart';

class UserExerciseDetails {
  int exerciseId;
  String? notes;
  WorkoutSet? pr;
  WorkoutSet? prSingle;
  WorkoutSet? last;
  WorkoutSet? lastSingle;
  List<WorkoutSet>? recentUses;

  UserExerciseDetails({
    required this.exerciseId,
    this.notes,
    this.pr,
    this.prSingle,
    this.last,
    this.lastSingle,
    this.recentUses,
  });

  String? getPRAsString({bool single = false}) {
    if (single) {
      if (prSingle == null) return null;
      if (prSingle!.weight! <= 0) return null;
      return truncateDouble(prSingle!.weight);
    }

    if (pr == null) return null;
    if (pr!.weight! <= 0) return null;
    return truncateDouble(pr!.weight);
  }

  String? getLastAsString({bool single = false}) {
    if (single) {
      if (lastSingle == null) return null;
      if (lastSingle!.weight! <= 0) return null;
      return truncateDouble(lastSingle!.weight);
    }

    if (last == null) return null;
    if (last!.weight! <= 0) return null;
    return truncateDouble(last!.weight);
  }
}
