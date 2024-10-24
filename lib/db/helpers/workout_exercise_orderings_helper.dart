import 'package:gymvision/db/classes/workout_exercise_ordering.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

  static insertWorkoutExerciseOrdering(WorkoutExerciseOrdering weo) async {
    try {
      final db = await DatabaseHelper.getDb();
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

  static removeExerciseFromOrderingForWorkout(int workoutId, int exerciseId) async {
    final ordering = await getWorkoutExerciseOrderingForWorkout(workoutId);
    if (ordering == null) return;

    var positions = ordering.getPositions();
    if (positions.contains(exerciseId)) {
      positions.remove(exerciseId);
      ordering.setPositions(positions);
      await updateWorkoutExerciseOrdering(ordering);
    }
  }

  static reorderPositioning(int workoutId, int oldIndex, int newIndex) async {
    var ordering = await getWorkoutExerciseOrderingForWorkout(workoutId);
    if (ordering == null) return;

    var positions = ordering.getPositions();
    var exerciseId = positions[oldIndex];
    positions.removeAt(oldIndex);
    positions.insert(newIndex, exerciseId);
    ordering.setPositions(positions);
    await updateWorkoutExerciseOrdering(ordering);
  }
}
