import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_category.dart';
import 'package:gymvision/classes/db/workout_exercise_ordering.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutModel {
  static Future<List<Workout>> getWorkoutsForDay(DateTime date) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_categories.id AS workoutCategoryId,
        workout_categories.category,
        workout_exercise_orderings.id AS weoId,
        workout_exercise_orderings.positions
      FROM workouts
      LEFT JOIN workout_exercise_orderings ON workouts.id = workout_exercise_orderings.workoutId
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      WHERE workouts.date LIKE '%${date.year}-${getMonthOrDayString(date.month)}-${getMonthOrDayString(date.day)}%'
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    for (var gm in groupedMaps.entries) {
      workouts.add(
        Workout(
          id: gm.key,
          date: parseDateTime(gm.value.first['date']),
          workoutCategories: processWorkoutCategories(gm.value),
          exerciseOrdering: WorkoutExerciseOrdering(
            id: gm.value.first['weoId'],
            workoutId: gm.key,
            positions: gm.value.first['positions'],
          ),
          done: await workoutIsDone(workoutId: gm.key, db: db),
          workoutExercses: await WorkoutExerciseModel.getWorkoutExercisesForWorkout(gm.key, db: db),
        ),
      );
    }

    return workouts;
  }

  static Future<List<Workout>> getAllWorkouts() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_categories.id AS workoutCategoryId,
        workout_categories.category,
        workout_exercise_orderings.id AS weoId,
        workout_exercise_orderings.positions
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      LEFT JOIN workout_exercise_orderings ON workouts.id = workout_exercise_orderings.workoutId
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    for (var gm in groupedMaps.entries) {
      workouts.add(
        Workout(
          id: gm.key,
          date: parseDateTime(gm.value.first['date']),
          workoutCategories: processWorkoutCategories(gm.value),
          exerciseOrdering: WorkoutExerciseOrdering(
            id: gm.value.first['weoId'],
            workoutId: gm.key,
            positions: gm.value.first['positions'],
          ),
          done: await workoutIsDone(workoutId: gm.key, db: db),
        ),
      );
    }

    return workouts;
  }

  static List<WorkoutCategory>? processWorkoutCategories(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;
    List<WorkoutCategory> workoutCategories = [];

    for (var m in list) {
      final workoutCategoryId = m['workoutCategoryId'];
      if (workoutCategoryId == null || workoutCategories.where((wc) => wc.id == workoutCategoryId).isNotEmpty) {
        continue; // skip dupe WCs
      }

      workoutCategories.add(WorkoutCategory(
        id: workoutCategoryId,
        updatedAt: tryParseDateTime(m['updatedAt']),
        createdAt: tryParseDateTime(m['createdAt']),
        workoutId: m['id'],
        category: stringToEnum<Category>(m['category'], Category.values)!,
      ));
    }

    return workoutCategories;
  }

  static Future<bool> workoutIsDone({required int workoutId, Database? db}) async {
    db ??= await DatabaseHelper.getDb();
    int? noIncompleteSets = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*)
      FROM workout_exercises
      WHERE workoutId = $workoutId AND done = 0;
    '''));
    return noIncompleteSets == 0;
  }

  static Future<Workout?> getWorkout({
    required int workoutId,
    bool includeCategories = false,
    bool includeWorkoutExercises = false,
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
        date: DateTime.parse(maps.first['date']),
        workoutCategories:
            includeCategories ? await WorkoutCategoryModel.getWorkoutCategoriesForWorkout(workoutId) : null,
        workoutExercses:
            includeWorkoutExercises ? await WorkoutExerciseModel.getWorkoutExercisesForWorkout(workoutId) : null,
        exerciseOrdering: includeWorkoutExercises
            ? await WorkoutExerciseOrderingsModel.getWorkoutExerciseOrderingForWorkout(workoutId)
            : null,
      );
    } catch (ex, stack) {
      await Sentry.captureException(ex, stackTrace: stack);
      return null;
    }
  }

  static Future<int> insertWorkout(Workout workout) async {
    final db = await DatabaseHelper.getDb();

    final now = DateTime.now();
    workout.createdAt = now;
    workout.updatedAt = now;

    final workoutId = await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await WorkoutExerciseOrderingsModel.insertWorkoutExerciseOrdering(WorkoutExerciseOrdering(workoutId: workoutId));
    return workoutId;
  }

  static deleteWorkout(int workoutId) async {
    final db = await DatabaseHelper.getDb();

    final wes = await WorkoutExerciseModel.getWorkoutExercisesForWorkout(workoutId, db: db);
    for (var we in wes) {
      await WorkoutExerciseModel.deleteWorkoutExercise(we.id!, db: db);
    }

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

    workout.updatedAt = DateTime.now();
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

    workout.updatedAt = DateTime.now();
    workout.date = DateTime(workout.date.year, workout.date.month, workout.date.day, newTime.hour, newTime.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int?> getMostRecentWorkoutIdForCategory(WorkoutCategory wc) async {
    final db = await DatabaseHelper.getDb();

    var workout = await getWorkout(workoutId: wc.workoutId);
    if (workout == null) return null;

    return Sqflite.firstIntValue(await db.rawQuery('''
      SELECT workoutId
      FROM workout_categories
      LEFT JOIN workouts ON workouts.id = workout_categories.workoutId
      WHERE category = ${wc.getCategoryEnumString()} AND workout_categories.id != ${wc.id} AND workouts.date < "${workout.date.toString()}"
      ORDER BY workouts.id DESC
      LIMIT 1;
    '''));
  }
}
