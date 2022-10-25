import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/exercise.dart';
import '../classes/workout.dart';
import '../db.dart';

class WorkoutsHelper {
  static Future<List<Workout>> getWorkouts() async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        categories.id AS categoryId,
        categories.name,
        categories.emoji
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      LEFT JOIN categories ON workout_categories.categoryId = categories.id
      ORDER BY workouts.date DESC;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps =
        groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];
    groupedMaps.forEach((k, v) {
      workouts.add(
        Workout(
          id: k,
          date: DateTime.parse(v.first['date']),
          workoutCategories: processWorkoutCategories(v),
        ),
      );
    });

    return workouts;
  }

  static List<WorkoutCategory>? processWorkoutCategories(
      List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;

    List<WorkoutCategory> workoutCategories = [];
    for (var m in list) {
      final categoryId = m['categoryId'];
      final name = m['name'];
      final emoji = m['emoji'];

      if (categoryId == null) continue;

      workoutCategories.add(
        WorkoutCategory(
          workoutId: m['id'],
          categoryId: categoryId,
          category: Category(
            id: categoryId,
            name: name,
            emoji: emoji,
          ),
        ),
      );
    }
    return workoutCategories;
  }

  static Future<Workout> getWorkout({
    required int workoutId,
    bool includeCategories = false,
    bool includeExercises = false,
  }) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [workoutId],
    );

    return Workout(
      id: workoutId,
      date: DateTime.parse(maps[0]['date']),
      workoutCategories: includeCategories
          ? await getWorkoutCategoriesForWorkout(workoutId)
          : null,
      workoutExercises: includeExercises
          ? await getWorkoutExercisesForWorkout(workoutId)
          : null,
    );
  }

  static Future<List<WorkoutCategory>?> getWorkoutCategoriesForWorkout(
    int workoutId,
  ) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_categories.id,
        workout_categories.categoryId,
        categories.name,
        categories.emoji
      FROM workout_categories
      LEFT JOIN categories ON workout_categories.categoryId = categories.id
      WHERE workout_categories.workoutId = $workoutId;
    ''');

    if (maps.isEmpty) return null;

    return maps
        .map(
          (map) => WorkoutCategory(
            id: map['id'],
            workoutId: workoutId,
            categoryId: map['categoryId'],
            category: Category(
              id: map['categoryId'],
              name: map['name'],
              emoji: map['emoji'],
            ),
          ),
        )
        .toList();
  }

  static Future<List<WorkoutExercise>?> getWorkoutExercisesForWorkout(
    int workoutId,
  ) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_exercises.id,
        workout_exercises.weight,
        workout_exercises.reps,
        workout_exercises.sets,
        workout_exercises.exerciseId,
        exercises.categoryId,
        exercises.name,
        exercises.weight AS exerciseWeight,
        exercises.max,
        exercises.reps AS exerciseReps,
        exercises.isSingle
      FROM workout_exercises
      LEFT JOIN exercises ON workout_exercises.exerciseId = exercises.id
      WHERE workout_exercises.workoutId = $workoutId;
    ''');

    if (maps.isEmpty) return null;

    return maps
        .map(
          (map) => WorkoutExercise(
            id: map['id'],
            workoutId: workoutId,
            exerciseId: map['exerciseId'],
            weight: map['weight'],
            reps: map['reps'],
            sets: map['sets'],
            exercise: Exercise(
              id: map['exerciseId'],
              categoryId: map['categoryId'],
              name: map['name'],
              weight: map['exerciseWeight'],
              max: map['max'],
              reps: map['exerciseReps'],
              isSingle: map['isSingle'] == 1,
            ),
          ),
        )
        .toList();
  }

  static Future<List<WorkoutExercise>> getWorkoutExercisesForExercise(
    int exerciseId,
  ) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_exercises.id,
        workout_exercises.sets,
        workout_exercises.exerciseId,
        workouts.id AS workoutId,
        workouts.date
      FROM workout_exercises
      LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
      WHERE workout_exercises.exerciseId = $exerciseId
      ORDER BY workouts.date DESC;
    ''');

    return List.generate(
      maps.length,
      (i) => WorkoutExercise(
        id: maps[i]['id'],
        workoutId: maps[i]['workoutId'],
        exerciseId: exerciseId,
        sets: maps[i]['sets'],
        workout: Workout(
          id: maps[i]['workoutId'],
          date: DateTime.parse(maps[i]['date']),
        ),
      ),
    );
  }

  static Future<int> insertWorkout(Workout workout) async {
    final db = await DatabaseHelper().getDb();
    final workoutId = await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return workoutId;
  }

  static addCategoriesToWorkout(int workoutId, List<int> categoryIds) async {
    final db = await DatabaseHelper().getDb();
    for (var exId in categoryIds) {
      await db.insert(
        'workout_categories',
        WorkoutCategory(
          workoutId: workoutId,
          categoryId: exId,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static addExerciseToWorkout(int workoutId, int exerciseId) async =>
      await addCategoriesToWorkout(workoutId, [exerciseId]);

  static addExercisesToWorkout(int workoutId, List<int> exerciseIds) async {
    final db = await DatabaseHelper().getDb();
    for (var exId in exerciseIds) {
      await db.insert(
        'workout_exercises',
        WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exId,
          sets: 3,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static addExerciseToWorkouts(
    int exerciseId,
    List<int> workoutIds,
    double weight,
    int reps,
    int sets,
  ) async {
    final db = await DatabaseHelper().getDb();
    for (var wId in workoutIds) {
      await db.insert(
        'workout_exercises',
        WorkoutExercise(
          workoutId: wId,
          exerciseId: exerciseId,
          sets: sets,
          weight: weight,
          reps: reps,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static updateWorkoutExercise(WorkoutExercise we) async {
    final db = await DatabaseHelper().getDb();
    await db.update(
      'workout_exercises',
      we.toMap(),
      where: 'id = ?',
      whereArgs: [we.id],
    );
  }

  static removeCategoryFromWorkout(int workoutCategoryId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_categories',
      where: 'id = ?',
      whereArgs: [workoutCategoryId],
    );
  }

  static removeExerciseFromWorkout(int workoutExerciseId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [workoutExerciseId],
    );
  }

  static deleteWorkout(int workoutId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_exercises',
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
    final db = await DatabaseHelper().getDb();
    final workout = await getWorkout(workoutId: id);
    workout.date = DateTime(newDate.year, newDate.month, newDate.day,
        workout.date.hour, workout.date.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static updateTime(int id, TimeOfDay newTime) async {
    final db = await DatabaseHelper().getDb();
    final workout = await getWorkout(workoutId: id);
    workout.date = DateTime(workout.date.year, workout.date.month,
        workout.date.day, newTime.hour, newTime.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
