import 'package:gymvision/db/classes/workout_set.dart';

class UserExerciseDetails {
  int? id;
  int? userId;
  int? exerciseId;
  String? notes;

  int? prId;
  WorkoutSet? pr;

  int? lastId;
  WorkoutSet? last;

  List<WorkoutSet>? recentUses;

  UserExerciseDetails({
    this.id,
    this.userId,
    this.exerciseId,
    this.notes,
    this.prId,
    this.pr,
    this.lastId,
    this.last,
    this.recentUses,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseId': exerciseId,
        'notes': notes,
        'prId': prId,
        'lastId': lastId,
      };

  String? getLastAsString() {
    if (last == null) return null;
    return last!.weight! % 1 == 0 ? last!.weight!.toStringAsFixed(0) : last!.weight!.toStringAsFixed(2);
  }

  String? getPRAsString() {
    if (pr == null) return null;
    return pr!.weight! % 1 == 0 ? pr!.weight!.toStringAsFixed(0) : pr!.weight!.toStringAsFixed(2);
  }
}
