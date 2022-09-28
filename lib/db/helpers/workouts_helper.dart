import 'package:collection/collection.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:sqflite/sqflite.dart';

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

  static insertWorkout(Workout workout) async {
    final db = await DatabaseHelper().getDb();
    await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Workout> getWorkout(int workoutId) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_exercises.id As workoutExercisesId,
        workout_exercises.exerciseId,
        workout_exercises.sets
      FROM workouts
      LEFT JOIN workout_exercises ON workouts.id = workout_exercises.workoutId
      WHERE workouts.id = $workoutId;
    ''');

    return Workout(
      id: workoutId,
      date: DateTime.parse(maps[0]['date']),
      exercises: processWorkoutExercises(workoutId, maps),
    );
  }

  processWorkoutExercises(int workoutId, List<Map<String, dynamic>> list) {
    if (list.length == 1) return null;

    List<WorkoutExercise> workoutExercises = [];
    for (var m in list) {
      if (m['exerciseId'] == null) continue;
      workoutExercises.add(
        WorkoutExercise(
          workoutId: workoutId,
          exerciseId: m['exerciseId'],
          sets: m['sets'],
        ),
      );
    }
    return workoutExercises;
  }
}
