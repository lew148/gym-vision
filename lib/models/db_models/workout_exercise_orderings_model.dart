import 'package:gymvision/classes/db/workouts/workout_exercise_ordering.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutExerciseOrderingsModel {
  static Future<WorkoutExerciseOrdering?> getWorkoutExerciseOrderingForWorkout(int workoutId) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_exercise_orderings',
      where: 'id = ?',
      whereArgs: [workoutId],
    );

    if (maps.isEmpty) return null;
    return WorkoutExerciseOrdering(
      id: maps.first['id'],
      updatedAt: tryParseDateTime(maps.first['updatedAt']),
      createdAt: tryParseDateTime(maps.first['createdAt']),
      workoutId: maps.first['workoutId'],
      positions: maps.first['positions'],
    );
  }

  static insertWorkoutExerciseOrdering(WorkoutExerciseOrdering weo) async {
    try {
      final db = await DatabaseHelper.getDb();
      final now = DateTime.now();
      weo.createdAt = now;
      weo.updatedAt = now;
      return await db.insert(
        'workout_exercise_orderings',
        weo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (ex, stack) {
      await Sentry.captureException(ex, stackTrace: stack);
    }
  }

  static updateWorkoutExerciseOrdering(WorkoutExerciseOrdering weo) async {
    try {
      final db = await DatabaseHelper.getDb();
      weo.updatedAt = DateTime.now();
      await db.update(
        'workout_exercise_orderings',
        weo.toMap(),
        where: 'id = ?',
        whereArgs: [weo.id],
      );
    } catch (ex, stack) {
      await Sentry.captureException(ex, stackTrace: stack);
    }
  }

  static removeExerciseFromOrderingForWorkout(int workoutExerciseId, int workoutId, [Database? db]) async {
    await DatabaseHelper.getDb(existingDb: db);

    final ordering = await getWorkoutExerciseOrderingForWorkout(workoutExerciseId);
    if (ordering == null) return;
    var positions = ordering.getPositions();
    if (positions.contains(workoutExerciseId)) {
      positions.remove(workoutExerciseId);
      ordering.setPositions(positions);
      await updateWorkoutExerciseOrdering(ordering);
    }
  }

  static reorderPositioning(int workoutId, int oldIndex, int newIndex) async {
    var ordering = await getWorkoutExerciseOrderingForWorkout(workoutId);
    if (ordering == null) return;
    var positions = ordering.getPositions();
    var workoutExerciseId = positions[oldIndex];
    positions.removeAt(oldIndex);
    positions.insert(newIndex, workoutExerciseId);
    ordering.setPositions(positions);
    await updateWorkoutExerciseOrdering(ordering);
  }
}
