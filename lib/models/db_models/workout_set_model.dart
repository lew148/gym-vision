import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutSetModel {
  static Future<List<WorkoutSet>?> getWorkoutSetsForExercise(String exerciseIdentifier) async =>
      await getWorkoutSets(whereStr: ' workout_exercises.exerciseIdentifier = "$exerciseIdentifier"');

  static getWorkoutSetsForWorkoutExercise(int workoutExerciseId, Database db) async =>
      await getWorkoutSets(whereStr: 'workout_sets.workoutExerciseId = $workoutExerciseId');

  static Future<WorkoutSet?> getWorkoutSet({required int id, bool shallow = false}) async {
    // todo: split shallow into new method
    var sets = await getWorkoutSets(whereStr: 'id = $id');
    return sets.isNotEmpty ? sets.first : null;
  }

  static Future<List<WorkoutSet>> getWorkoutSets({String? whereStr}) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.updatedAt,
        workout_sets.createdAt,
        workout_sets.workoutExerciseId,
        workout_sets.weight,
        workout_sets.reps,
        workout_sets.time,
        workout_sets.distance,
        workout_sets.calsBurned,
        workout_exercises.id AS workoutExerciseId,
        workout_exercises.exerciseIdentifier,
        workout_exercises.workoutId,
        workout_exercises.done,
        workouts.id AS workoutId,
        workouts.date
      FROM workout_sets
      LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
      LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
      ${whereStr == null ? '' : 'WHERE $whereStr'};
    ''');

    List<WorkoutSet> sets = [];
    for (var map in maps) {
      sets.add(
        WorkoutSet(
          id: map['id'],
          updatedAt: tryParseDateTime(map['updatedAt']),
          createdAt: tryParseDateTime(map['createdAt']),
          workoutExerciseId: map['workoutExerciseId'],
          weight: map['weight'],
          reps: map['reps'],
          time: tryParseDuration(map['time']),
          distance: map['distance'],
          calsBurned: map['calsBurned'],
          workoutExercise: WorkoutExercise(
            id: map['workoutExerciseId'],
            workoutId: map['workoutId'],
            exerciseIdentifier: map['exerciseIdentifier'],
            done: map['done'] == 1,
            workout: Workout(
              id: map['workoutId'],
              date: parseDateTime(map['date']),
            ),
          ),
        ),
      );
    }

    return sets;
  }

  static Future addSetToWorkout(WorkoutSet ws) async {
    try {
      final db = await DatabaseHelper.getDb();
      final we = await WorkoutExerciseModel.getWorkoutExercise(ws.workoutExerciseId, db);
      if (we == null) return;
      final ordering = await WorkoutExerciseOrderingsModel.getWorkoutExerciseOrderingForWorkout(we.workoutId);

      var now = DateTime.now();
      ws.updatedAt = now;
      ws.createdAt = now;
      await db.insert(
        'workout_sets',
        ws.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (ordering != null && !ordering.getPositions().contains(we.id)) {
        final newOrder = ordering.getPositions();
        newOrder.add(we.id!);
        ordering.setPositions(newOrder);
        await WorkoutExerciseOrderingsModel.updateWorkoutExerciseOrdering(ordering);
      }
    } catch (ex, stack) {
      await Sentry.captureException(ex, stackTrace: stack);
    }
  }

  static Future removeSet(int setId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  static Future updateWorkoutSet(WorkoutSet ws) async {
    final db = await DatabaseHelper.getDb();

    ws.updatedAt = DateTime.now();
    await db.update(
      'workout_sets',
      ws.toMap(),
      where: 'id = ?',
      whereArgs: [ws.id],
    );
  }

  static Future removeSetsForWorkoutExercise(int workoutExerciseId, [Database? db]) async {
    db ??= await DatabaseHelper.getDb();
    await db.delete(
      'workout_sets',
      where: 'workoutExerciseId = ?',
      whereArgs: [workoutExerciseId],
    );
  }

  static Future<WorkoutSet?> getPr({required String exerciseIdentifier, Database? existingDb}) async {
    final db = await DatabaseHelper.getDb(existingDb: existingDb);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      WITH max_table AS (
        SELECT *
        FROM workout_sets
        LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
        LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
        INNER JOIN (
          SELECT MAX(workout_sets.weight) AS max_weight
          FROM workout_sets
          LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
          WHERE workout_exercises.exerciseIdentifier = "$exerciseIdentifier" AND workout_exercises.done = 1 AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
        ) AS b ON workout_sets.weight = b.max_weight
        WHERE workout_exercises.exerciseIdentifier = "$exerciseIdentifier" AND workout_exercises.done = 1 AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
      )

      SELECT *
      FROM max_table
      INNER JOIN (
        SELECT MAX(max_table.date) AS max_date
        FROM max_table
      ) AS b ON max_table.date = b.max_date
      ORDER BY reps DESC;
    ''');

    if (maps.isEmpty) return null;
    return WorkoutSet(
      id: maps.first['id'],
      updatedAt: tryParseDateTime(maps.first['updatedAt']),
      createdAt: tryParseDateTime(maps.first['createdAt']),
      workoutExerciseId: maps.first['workoutExerciseId'],
      done: maps.first['done'] == 1,
      weight: maps.first['weight'],
      reps: maps.first['reps'],
      time: tryParseDuration(maps.first['time']),
      distance: maps.first['distance'],
      calsBurned: maps.first['calsBurned'],
      workoutExercise: WorkoutExercise(
        id: maps.first['workoutExerciseId'],
        workoutId: maps.first['workoutId'],
        exerciseIdentifier: maps.first['exerciseIdentifier'],
        workout: Workout(
          id: maps.first['workoutId'],
          date: parseDateTime(maps.first['date']),
        ),
      ),
    );
  }

  static Future<WorkoutSet?> getLast({required String exerciseIdentifier, Database? existingDb}) async {
    final db = await DatabaseHelper.getDb(existingDb: existingDb);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.updatedAt,
        workout_sets.createdAt,
        workout_sets.workoutExerciseId,
        workout_sets.weight,
        workout_sets.reps,
        workout_sets.time,
        workout_sets.distance,
        workout_sets.calsBurned,
        workout_exercises.id AS workoutExerciseId,
        workout_exercises.exerciseIdentifier,
        workout_exercises.done,
        workout_exercises.workoutId,
        workouts.id AS workoutId,
        workouts.date
      FROM workout_sets
      LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
      LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
      WHERE workout_exercises.exerciseIdentifier = "$exerciseIdentifier" AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
      ORDER BY workout_sets.updatedAt DESC
      LIMIT 1;
    ''');

    if (maps.isEmpty) return null;
    return WorkoutSet(
      id: maps.first['id'],
      updatedAt: tryParseDateTime(maps.first['updatedAt']),
      createdAt: tryParseDateTime(maps.first['createdAt']),
      workoutExerciseId: maps.first['workoutExerciseId'],
      // done: maps.first['done'] == 1,
      weight: maps.first['weight'],
      reps: maps.first['reps'],
      time: tryParseDuration(maps.first['time']),
      distance: maps.first['distance'],
      calsBurned: maps.first['calsBurned'],
      workoutExercise: WorkoutExercise(
        id: maps.first['workoutExerciseId'],
        workoutId: maps.first['workoutId'],
        exerciseIdentifier: maps.first['exerciseIdentifier'],
        done: maps.first['done'] == 1,
        workout: Workout(
          id: maps.first['workoutId'],
          date: parseDateTime(maps.first['date']),
        ),
      ),
    );
  }
}
