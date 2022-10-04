import 'package:collection/collection.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/exercise.dart';
import '../classes/workout.dart';
import '../db.dart';

class WorkoutsHelper {
  Future<List<Workout>> getWorkouts() async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT workouts.id, workouts.date, categories.name As categoryName
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
      LEFT JOIN categories ON workout_categories.categoryId = categories.id;
    ''');

    final Map<int, List<Map<String, dynamic>>> groupedMaps =
        groupBy<Map<String, dynamic>, int>(maps, (x) => x['id']);

    List<Workout> workouts = [];
    groupedMaps.forEach((k, v) {
      workouts.add(
        Workout(
          id: k,
          date: DateTime.parse(v.first['date']),
          categoryStrings: processWorkoutCategoryStrings(v),
        ),
      );
    });

    return workouts;
  }

  processWorkoutCategoryStrings(List<Map<String, dynamic>> list) {
    if (list.length == 1) return null;

    List<String> workoutCategoryStrings = [];
    for (var m in list) {
      if (m['categoryName'] == null) continue;
      workoutCategoryStrings.add(m['categoryName']);
    }
    return workoutCategoryStrings;
  }

  Future<Workout> getWorkout(int workoutId) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_exercises.id As workoutExerciseId,
        workout_exercises.exerciseId,
        workout_exercises.sets,
        exercises.categoryId,
        exercises.name,
        exercises.weight,
        exercises.max,
        exercises.reps,
        exercises.isSingle
      FROM workouts
      LEFT JOIN workout_exercises ON workouts.id = workout_exercises.workoutId
      LEFT JOIN exercises ON workout_exercises.exerciseId = exercises.id
      WHERE workouts.id = $workoutId;
    ''');

    return Workout(
      id: workoutId,
      date: DateTime.parse(maps[0]['date']),
      workoutExercises: processWorkoutExercises(workoutId, maps),
    );
  }

  processWorkoutExercises(int workoutId, List<Map<String, dynamic>> list) {
    if (list.length == 1) return null;

    List<WorkoutExercise> workoutExercises = [];
    for (var map in list) {
      if (map['exerciseId'] == null) continue;
      workoutExercises.add(
        WorkoutExercise(
          id: map['workoutExerciseId'],
          workoutId: workoutId,
          exerciseId: map['exerciseId'],
          sets: map['sets'],
          exercise: Exercise(
            id: map['exerciseId'],
            categoryId: map['categoryId'],
            name: map['name'],
            weight: map['weight'],
            max: map['max'],
            reps: map['reps'],
            isSingle: map['isSingle'] == 1,
          ),
        ),
      );
    }
    return workoutExercises;
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

  Future<List<WorkoutExercise>> getExercisesForWorkout(int workoutId) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_exercises.id,
        workout_exercises.sets,
        workout_exercises.exerciseId,
        exercises.categoryId,
        exercises.name,
        exercises.weight,
        exercises.max,
        exercises.reps,
        exercises.isSingle
      FROM workout_exercises
      LEFT JOIN exercises ON workout_exercises.exerciseId = exercises.id
      WHERE workout_exercises.workoutId = $workoutId;
    ''');

    return maps
        .map(
          (map) => WorkoutExercise(
            id: map['id'],
            workoutId: workoutId,
            exerciseId: map['exerciseId'],
            sets: map['sets'],
            exercise: Exercise(
              id: map['exerciseId'],
              categoryId: map['categoryId'],
              name: map['name'],
              weight: map['weight'],
              max: map['max'],
              reps: map['reps'],
              isSingle: map['isSingle'] == 1,
            ),
          ),
        )
        .toList();
  }

  removeExerciseFromWorkout(int workoutExerciseId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [workoutExerciseId],
    );
  }

  deleteWorkout(int workoutId) async {
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
}
