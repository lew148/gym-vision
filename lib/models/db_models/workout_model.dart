import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
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
        workouts.endDate,
        workouts.exerciseOrder,
        workout_categories.id AS workoutCategoryId,
        workout_categories.category
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      WHERE workouts.date LIKE '%${date.year}-${NumberHelper.getIntTwoDigitsString(date.month)}-${NumberHelper.getIntTwoDigitsString(date.day)}%'
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    for (var gm in groupedMaps.entries) {
      workouts.add(
        Workout(
          id: gm.key,
          date: DateTimeHelper.parseDateTime(gm.value.first['date']),
          endDate: DateTimeHelper.tryParseDateTime(gm.value.first['endDate']),
          exerciseOrder: gm.value.first['exerciseOrder'],
          workoutCategories: processWorkoutCategories(gm.value),
          workoutExercises: await WorkoutExerciseModel.getWorkoutExercisesForWorkout(gm.key, db: db),
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
        workouts.endDate,
        workouts.exerciseOrder,
        workout_categories.id AS workoutCategoryId,
        workout_categories.category,
        workout_exercises.id as weId
      FROM workouts
      LEFT JOIN workout_exercises ON workouts.id = workout_exercises.workoutId
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    for (var gm in groupedMaps.entries) {
      workouts.add(
        Workout(
          id: gm.key,
          date: DateTimeHelper.parseDateTime(gm.value.first['date']),
          endDate: DateTimeHelper.tryParseDateTime(gm.value.first['endDate']),
          exerciseOrder: gm.value.first['exerciseOrder'],
          workoutCategories: processWorkoutCategories(gm.value),
          isEmpty: gm.value.first['weId'] == null,
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
        updatedAt: DateTimeHelper.tryParseDateTime(m['updatedAt']),
        createdAt: DateTimeHelper.tryParseDateTime(m['createdAt']),
        workoutId: m['id'],
        category: EnumHelper.stringToEnum<Category>(m['category'], Category.values)!,
      ));
    }

    return workoutCategories;
  }

  static Future<Workout?> getWorkout({
    required int workoutId,
    bool includeCategories = false,
    bool includeWorkoutExercises = false,
  }) async {
    try {
      final db = await DatabaseHelper.getDb();
      final List<Map<String, dynamic>> maps = await db.query('workouts', where: 'id = ?', whereArgs: [workoutId]);
      if (maps.isEmpty) return null;

      return Workout(
        id: workoutId,
        date: DateTimeHelper.parseDateTime(maps.first['date']),
        endDate: DateTimeHelper.tryParseDateTime(maps.first['endDate']),
        exerciseOrder: maps.first['exerciseOrder'],
        workoutCategories:
            includeCategories ? await WorkoutCategoryModel.getWorkoutCategoriesForWorkout(workoutId) : null,
        workoutExercises:
            includeWorkoutExercises ? await WorkoutExerciseModel.getWorkoutExercisesForWorkout(workoutId) : null,
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

  static updateTime(int id, DateTime newTime) async {
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
      WHERE category = "${wc.getCategoryEnumString()}" AND workout_categories.id != ${wc.id} AND workouts.date < "${workout.date.toString()}"
      ORDER BY workouts.id DESC
      LIMIT 1;
    '''));
  }

  static Future<bool> updateWorkout(Workout workout) async {
    final db = await DatabaseHelper.getDb();
    workout.updatedAt = DateTime.now();
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );

    return true;
  }

  static Future<String?> getWorkoutExportString(int id) async {
    final fullWorkout = await getWorkout(workoutId: id, includeCategories: true, includeWorkoutExercises: true);
    if (fullWorkout == null) return null;

    final workoutExercises = fullWorkout.workoutExercises?.map((we) => we.toMap()).toList();
    if (workoutExercises != null) {
      for (int i = 0; i < workoutExercises.length; i++) {
        final we = workoutExercises[i];
        we['sets'] = fullWorkout.workoutExercises
            ?.firstWhereOrNull((w) => w.id == we['id'])
            ?.workoutSets
            ?.map((ws) => ws.toMap())
            .toList();
      }
    }

    final workoutMap = fullWorkout.toMap();
    workoutMap['categories'] = fullWorkout.workoutCategories?.map((wc) => wc.toMap()).toList();
    workoutMap['workoutExercises'] = workoutExercises?.toList();
    return jsonEncode(workoutMap);
  }

  static Future<bool> importWorkout(String input) async {
    if (input.isEmpty) return false;

    if (input[0] != '[') {
      // wrap single imports in brackets to handle as bulk
      input = '[$input]';
    }

    try {
      final db = await DatabaseHelper.getDb();
      final maps = jsonDecode(input);
      for (var workoutMap in maps) {
        var workoutId = await db.insert('workouts', {
          'updatedAt': workoutMap['updatedAt'],
          'createdAt': workoutMap['createdAt'],
          'date': workoutMap['date'],
          'endDate': workoutMap['endDate'],
          'exerciseOrder': '', // import clears order, as IDs will change
        });

        if (workoutId == 0) return false;

        for (var wc in workoutMap['categories']) {
          await db.insert('workout_categories', {
            'workoutId': workoutId,
            'updatedAt': wc['updatedAt'],
            'createdAt': wc['createdAt'],
            'category': wc['category'],
          });
        }

        for (var we in workoutMap['workoutExercises']) {
          var workoutExerciseId = await db.insert('workout_exercises', {
            'workoutId': workoutId,
            'updatedAt': we['updatedAt'],
            'createdAt': we['createdAt'],
            'exerciseIdentifier': we['exerciseIdentifier'],
            'done': we['done'],
          });

          if (workoutExerciseId == 0) continue;

          for (var ws in we['sets']) {
            await db.insert('workout_sets', {
              'workoutExerciseId': workoutExerciseId,
              'updatedAt': ws['updatedAt'],
              'createdAt': ws['createdAt'],
              'done': ws['done'],
              'weight': ws['weight'],
              'reps': ws['reps'],
              'time': ws['time'],
              'distance': ws['distance'],
              'calsBurned': ws['calsBurned'],
            });
          }
        }
      }

      return true;
    } catch (ex) {
      return false;
    }
  }
}
