import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise_ordering.dart';
import 'package:gymvision/db/helpers/workout_exercise_orderings_helper.dart';
import 'package:gymvision/db/helpers/workout_sets_helper.dart';
import 'package:gymvision/globals.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/workout.dart';
import '../db.dart';

class WorkoutsHelper {
  static Future<List<Workout>> getWorkoutsForDay(DateTime date) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_categories.id AS workoutCategoryId,
        workout_categories.categoryShellId,
        workout_exercise_orderings.id AS weoId,
        workout_exercise_orderings.positions
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      LEFT JOIN workout_exercise_orderings ON workouts.id = workout_exercise_orderings.workoutId
      WHERE workouts.date LIKE '%${date.year}-${getMonthOrDayString(date.month)}-${getMonthOrDayString(date.day)}%'
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    groupedMaps.forEach((k, v) async {
      workouts.add(
        Workout(
          id: k,
          date: DateTime.parse(v.first['date']),
          workoutCategories: processWorkoutCategories(v),
          ordering: v.first['positions'] != null
              ? WorkoutExerciseOrdering(
                  id: v.first['weoId'],
                  workoutId: k,
                  positions: v.first['positions'],
                )
              : null,
        ),
      );
    });

    for (var w in workouts) {
      w.done = await workoutIsDone(workoutId: w.id!, db: db);
      w.workoutSets = await WorkoutSetsHelper.getWorkoutSetsForWorkout(w.id!);
    }

    return workouts;
  }

  static Future<List<Workout>> getWorkouts() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_categories.id AS workoutCategoryId,
        workout_categories.categoryShellId,
        workout_exercise_orderings.id AS weoId,
        workout_exercise_orderings.positions
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      LEFT JOIN workout_exercise_orderings ON workouts.id = workout_exercise_orderings.workoutId
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    groupedMaps.forEach((k, v) async {
      workouts.add(
        Workout(
          id: k,
          date: DateTime.parse(v.first['date']),
          workoutCategories: processWorkoutCategories(v),
          ordering: v.first['positions'] != null
              ? WorkoutExerciseOrdering(
                  id: v.first['weoId'],
                  workoutId: k,
                  positions: v.first['positions'],
                )
              : null,
        ),
      );
    });

    for (var w in workouts) {
      w.done = await workoutIsDone(workoutId: w.id!, db: db);
    }

    return workouts;
  }

  static List<WorkoutCategory>? processWorkoutCategories(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;

    List<WorkoutCategory> workoutCategories = [];
    for (var m in list) {
      final workoutCategoryId = m['workoutCategoryId'];
      if (workoutCategoryId == null) continue;
      if (workoutCategories.where((wc) => wc.id == workoutCategoryId).isNotEmpty) continue; // skip dupe WCs

      workoutCategories.add(
        WorkoutCategory(
          id: workoutCategoryId,
          workoutId: m['id'],
          categoryShellId: m['categoryShellId'],
        ),
      );
    }

    return workoutCategories;
  }

  static Future<bool> workoutIsDone({required int workoutId, Database? db}) async {
    db ??= await DatabaseHelper.getDb();
    int? noIncompleteSets = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*)
      FROM workout_sets
      WHERE workoutId = $workoutId AND done = 0;
    '''));
    return noIncompleteSets == 0;
  }

  static Future<Workout?> getWorkout({
    required int workoutId,
    bool includeCategories = false,
    bool includeSets = false,
  }) async {
    try {
      final db = await DatabaseHelper.getDb();
      final List<Map<String, dynamic>> maps = await db.query(
        'workouts',
        where: 'id = ?',
        whereArgs: [workoutId],
      );

      return Workout(
        id: workoutId,
        date: DateTime.parse(maps[0]['date']),
        workoutCategories: includeCategories ? await getWorkoutCategoriesForWorkout(workoutId) : null,
        workoutSets: includeSets ? await WorkoutSetsHelper.getWorkoutSetsForWorkout(workoutId) : null,
        ordering:
            includeSets ? await WorkoutExerciseOrderingsHelper.getWorkoutExerciseOrderingForWorkout(workoutId) : null,
      );
    } catch (ex, stack) {
      await Sentry.captureException(ex, stackTrace: stack);
      return null;
    }
  }

  static Future<List<WorkoutCategory>?> getWorkoutCategoriesForWorkout(
    int workoutId,
  ) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_categories',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );

    if (maps.isEmpty) return null;

    return maps
        .map(
          (map) => WorkoutCategory(
            id: map['id'],
            workoutId: workoutId,
            categoryShellId: map['categoryShellId'],
          ),
        )
        .toList();
  }

  static Future<int> insertWorkout(Workout workout) async {
    final db = await DatabaseHelper.getDb();
    final workoutId = await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await WorkoutExerciseOrderingsHelper.insertWorkoutExerciseOrdering(WorkoutExerciseOrdering(workoutId: workoutId));
    return workoutId;
  }

  static setWorkoutCategories(int workoutId, List<int> shellIds) async {
    final db = await DatabaseHelper.getDb();

    // caregoryIds == category shell ids (in workout_category_helper.dart)
    final existingWCs = await getWorkoutCategoriesForWorkout(workoutId);
    final newIds = shellIds;

    if (existingWCs != null && existingWCs.isNotEmpty) {
      for (var ewc in existingWCs) {
        if (shellIds.contains(ewc.categoryShellId)) {
          newIds.remove(ewc.categoryShellId);
        } else {
          await removeWorkoutCategory(ewc.id!);
        }
      }
    }

    for (var exId in newIds) {
      await db.insert(
        'workout_categories',
        WorkoutCategory(
          workoutId: workoutId,
          categoryShellId: exId,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static removeWorkoutCategory(int shellId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_categories',
      where: 'id = ?',
      whereArgs: [shellId],
    );
  }

  static deleteWorkout(int workoutId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_sets',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );

    await db.delete(
      'workout_categories',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );

    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  static updateDate(int id, DateTime newDate) async {
    final db = await DatabaseHelper.getDb();
    final workout = await getWorkout(workoutId: id);
    if (workout == null) return;

    workout.date = DateTime(newDate.year, newDate.month, newDate.day, workout.date.hour, workout.date.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static updateTime(int id, TimeOfDay newTime) async {
    final db = await DatabaseHelper.getDb();
    final workout = await getWorkout(workoutId: id);
    if (workout == null) return;

    workout.date = DateTime(workout.date.year, workout.date.month, workout.date.day, newTime.hour, newTime.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int?> getMostRecentWorkoutForCategory(WorkoutCategory wc) async {
    final db = await DatabaseHelper.getDb();

    var workout = await getWorkout(workoutId: wc.workoutId);
    if (workout == null) return null;

    return Sqflite.firstIntValue(await db.rawQuery('''
      SELECT workoutId
      FROM workout_categories
      LEFT JOIN workouts ON workouts.id = workout_categories.workoutId
      WHERE categoryShellId = ${wc.categoryShellId} AND workout_categories.id != ${wc.id} AND workouts.date < "${workout.date.toString()}"
      ORDER BY workouts.id DESC
      LIMIT 1;
    '''));
  }
}
