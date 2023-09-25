import 'package:gymvision/db/classes/workout_set.dart';

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
    return last!.weight! % 1 == 0 ? last!.weight!.toStringAsFixed(0) : last!.weight!.toStringAsFixed(2);
  }

  String? getPRAsString() {
    if (pr == null) return null;
    return pr!.weight! % 1 == 0 ? pr!.weight!.toStringAsFixed(0) : pr!.weight!.toStringAsFixed(2);
  }
}
