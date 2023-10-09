import 'package:gymvision/db/classes/workout_exercise_ordering.dart';
import 'package:sqflite/sqflite.dart';

import '../db.dart';

class WorkoutExerciseOrderingsHelper {
  static Future<WorkoutExerciseOrdering?> getWorkoutExerciseOrderingForWorkout(int workoutId) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_exercise_orderings',
      where: 'id = ?',
      whereArgs: [workoutId],
    );

    if (maps.isEmpty) return null;

    return WorkoutExerciseOrdering(
      id: maps[0]['id'],
      workoutId: workoutId,
      positions: maps[0]['positions'],
    );
  }

  static Future<int> insertWorkoutExerciseOrdering(WorkoutExerciseOrdering weo) async {
    final db = await DatabaseHelper.getDb();
    return await db.insert(
      'workout_exercise_orderings',
      weo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static updateWorkoutExerciseOrdering(WorkoutExerciseOrdering weo) async {
    final db = await DatabaseHelper.getDb();
    await db.update(
      'workout_exercise_orderings',
      weo.toMap(),
      where: 'id = ?',
      whereArgs: [weo.id],
    );
  }

  static reorderPositioning(int workoutId, int oldIndex, int newIndex) async {
    var ordering = await getWorkoutExerciseOrderingForWorkout(workoutId);
    if (ordering == null) return;

    var positioning = ordering.getPositions();
    var exerciseId = positioning[oldIndex];
    positioning.removeAt(oldIndex);
    positioning.insert(newIndex, exerciseId);
    ordering.setPositions(positioning);

    await updateWorkoutExerciseOrdering(ordering);
  }
}
