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

    final Map<int, List<Map<String, dynamic>>> groupedMaps = groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];

    groupedMaps.forEach((k, v) async {
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

  static List<WorkoutCategory>? processWorkoutCategories(List<Map<String, dynamic>> list) {
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
      workoutCategories: includeCategories ? await getWorkoutCategoriesForWorkout(workoutId) : null,
      workoutExercises: includeExercises ? await getWorkoutExercisesForWorkout(workoutId) : null,
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
  ) async =>
      await getWorkoutExercises('workoutId', workoutId);

  static Future<List<WorkoutExercise>?> getWorkoutExercisesForExercise(
    int exerciseId,
  ) async =>
      await getWorkoutExercises('exerciseId', exerciseId);

  static Future<List<WorkoutExercise>> getWorkoutExercises(
    String whereProp,
    int value,
  ) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_exercises.id,
        workout_exercises.weight,
        workout_exercises.reps,
        workout_exercises.sets,
        workout_exercises.done,
        workout_exercises.workoutId,
        workout_exercises.exerciseId,
        workouts.date,
        exercises.categoryId,
        exercises.name,
        exercises.weight AS exerciseWeight,
        exercises.max,
        exercises.reps AS exerciseReps,
        exercises.isSingle,
        exercises.notes
      FROM workout_exercises
      LEFT JOIN exercises ON workout_exercises.exerciseId = exercises.id
      LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
      WHERE workout_exercises.$whereProp = $value;
    ''');

    return maps
        .map(
          (map) => WorkoutExercise(
            id: map['id'],
            workoutId: map['workoutId'],
            exerciseId: map['exerciseId'],
            weight: map['weight'],
            reps: map['reps'],
            sets: map['sets'],
            done: map['done'] == 1,
            exercise: Exercise(
              id: map['exerciseId'],
              categoryId: map['categoryId'],
              name: map['name'],
              weight: map['exerciseWeight'],
              max: map['max'],
              reps: map['exerciseReps'],
              isSingle: map['isSingle'] == 1,
              notes: map['notes'] ?? '',
            ),
            workout: Workout(
              id: map['workoutId'],
              date: DateTime.parse(map['date']),
            ),
          ),
        )
        .toList();
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

  static setWorkoutCategories(int workoutId, List<int> categoryIds) async {
    final db = await DatabaseHelper().getDb();

    final existingWCs = await getWorkoutCategoriesForWorkout(workoutId);
    final newCategoryIds = categoryIds;

    if (existingWCs != null && existingWCs.isNotEmpty) {
      for (var ewc in existingWCs) {
        if (categoryIds.contains(ewc.categoryId)) {
          newCategoryIds.remove(ewc.categoryId);
        } else {
          await removeCategoryFromWorkout(ewc.id!);
        }
      }
    }

    for (var exId in newCategoryIds) {
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

  static addExerciseToWorkout({
    required int exerciseId,
    required int workoutId,
    double? weight,
    int? reps,
    int? sets,
    bool? done,
  }) async {
    final db = await DatabaseHelper().getDb();
    await db.insert(
      'workout_exercises',
      WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        sets: sets ?? 3,
        weight: weight ?? 0,
        reps: reps ?? 0,
        done: done ?? false,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  static splitAWorkoutExerciseSet(WorkoutExercise we) async {
    final db = await DatabaseHelper().getDb();

    we.sets = we.sets! - 1;
    await db.update(
      'workout_exercises',
      we.toMap(),
      where: 'id = ?',
      whereArgs: [we.id],
    );

    await addExerciseToWorkout(
      exerciseId: we.exerciseId,
      workoutId: we.workoutId,
      weight: we.weight,
      reps: we.reps!,
      sets: 1,
      done: we.done,
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

   static removegroupedExercisesFromWorkout(int workoutId, int exerciseId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_exercises',
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
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
    workout.date = DateTime(newDate.year, newDate.month, newDate.day, workout.date.hour, workout.date.minute);
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
    workout.date = DateTime(workout.date.year, workout.date.month, workout.date.day, newTime.hour, newTime.minute);
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
