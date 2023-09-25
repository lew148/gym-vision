import 'package:gymvision/db/helpers/workout_sets_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/user_exercise_details.dart';
import '../db.dart';

class UserExerciseDetailsHelper {
  static Future<UserExerciseDetails?> getUserDetailsForExercise({
    required int exerciseId,
    required bool includeRecentUses,
    Database? existingDb,
  }) async {
    final db = await DatabaseHelper().getDb(existingDb: existingDb);
    return UserExerciseDetails(
      exerciseId: exerciseId,
      // notes: map['notes'],
      pr: await WorkoutSetsHelper.getPr(exerciseId: exerciseId, existingDb: db),
      last: await WorkoutSetsHelper.getLast(exerciseId: exerciseId, existingDb: db),
      recentUses: includeRecentUses ? await WorkoutSetsHelper.getWorkoutSetsForExercise(exerciseId) : null,
    );
  }
}
