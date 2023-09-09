import 'package:gymvision/db/helpers/workout_sets_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/user_exercise_details.dart';
import '../db.dart';

class UserExerciseDetailsHelper {
  static Future<UserExerciseDetails?> getUserDetailsForExercise(int exerciseId, bool includeRecentUses) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'user_exercise_details',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );

    if (maps.isEmpty) return null;

    final map = maps[0];
    return UserExerciseDetails(
      id: map['id'],
      exerciseId: map['exerciseId'],
      notes: map['notes'],
      pr: map['prId'] != null ? await WorkoutSetsHelper.getWorkoutSet(id: map['prId'], shallow: true) : null,
      last: map['lastId'] != null ? await WorkoutSetsHelper.getWorkoutSet(id: map['lastId'], shallow: true) : null,
      recentUses: includeRecentUses ? await WorkoutSetsHelper.getWorkoutSetsForExercise(map['exerciseId']) : null,
    );
  }

  static insertUserExerciseDetails(UserExerciseDetails details) async {
    final db = await DatabaseHelper().getDb();
    await db.insert(
      'user_exercise_details',
      details.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static updateUserExerciseDetails(UserExerciseDetails details) async {
    final db = await DatabaseHelper().getDb();
    await db.update(
      'user_exercise_details',
      details.toMap(),
      where: 'id = ?',
      whereArgs: [details.id],
    );
  }
}
