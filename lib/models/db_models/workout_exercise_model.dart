import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutExerciseModel {
  static Future<WorkoutExercise?> getWorkoutExercise(int workoutExerciseId, [Database? db]) async {
    db ??= await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [workoutExerciseId],
    );

    if (maps.isEmpty) return null;
    return WorkoutExercise(
      id: maps.first['id'],
      updatedAt: DateTime.parse(maps.first['updatedAt']),
      createdAt: DateTime.parse(maps.first['createdAt']),
      workoutId: maps.first['workoutId'],
      exerciseIdentifier: maps.first['exerciseIdentifier'],
      done: maps.first['done'] == 1,
    );
  }

  static Future<WorkoutExercise?> getWorkoutExerciseByWorkoutAndExercise(
      int workoutId, String exerciseIdentifier) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_exercises',
      where: 'workoutId = ? AND exerciseIdentifier = ?',
      whereArgs: [workoutId, exerciseIdentifier],
    );

    if (maps.isEmpty) return null;
    return WorkoutExercise(
      id: maps.first['id'],
      updatedAt: DateTime.parse(maps.first['updatedAt']),
      createdAt: DateTime.parse(maps.first['createdAt']),
      workoutId: maps.first['workoutId'],
      exerciseIdentifier: maps.first['exerciseIdentifier'],
      done: maps.first['done'] == 1,
    );
  }

  static Future deleteWorkoutExercise(int workoutExerciseId, {Database? db}) async {
    db ??= await DatabaseHelper.getDb();

    var we = await getWorkoutExercise(workoutExerciseId, db);
    if (we == null) return;

    await WorkoutSetModel.removeSetsForWorkoutExercise(workoutExerciseId, db);

    await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [workoutExerciseId],
    );

    await WorkoutExerciseOrderingsModel.removeExerciseFromOrderingForWorkout(workoutExerciseId, we.workoutId, db);
  }

  static Future<List<WorkoutExercise>> getWorkoutExercisesForWorkout(int workoutId, {Database? db}) async {
    db ??= await DatabaseHelper.getDb();

    final List<Map<String, dynamic>> maps = await db.query(
      'workout_exercises',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );

    if (maps.isEmpty) return [];

    List<WorkoutExercise> workoutExercises = [];

    for (var m in maps) {
      workoutExercises.add(WorkoutExercise(
        id: m['id'],
        updatedAt: DateTime.parse(m['updatedAt']),
        createdAt: DateTime.parse(m['createdAt']),
        workoutId: m['workoutId'],
        exerciseIdentifier: m['exerciseIdentifier'],
        exercise: DefaultExercisesModel.getExerciseByIdentifier(m['exerciseIdentifier']),
        workoutSets: await WorkoutSetModel.getWorkoutSetsForWorkoutExercise(m['id'], db),
        done: m['done'] == 1,
      ));
    }

    return workoutExercises;
  }

  static Future<int> insertWorkoutExercise(WorkoutExercise we) async {
    var db = await DatabaseHelper.getDb();
    final now = DateTime.now();
    we.updatedAt = now;
    we.createdAt = now;
    final id = await db.insert('workout_exercises', we.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    final existingOrdering = await WorkoutExerciseOrderingsModel.getWorkoutExerciseOrderingForWorkout(we.workoutId);

    if (existingOrdering != null) {
      existingOrdering.addExerciseToOrdering(id);
      await WorkoutExerciseOrderingsModel.updateWorkoutExerciseOrdering(existingOrdering);
    }

    return id;
  }

  static Future updateWorkoutExercise(WorkoutExercise workoutExercise) async {
    final db = await DatabaseHelper.getDb();
    await db.update(
      'workout_exercises',
      workoutExercise.toMap(),
      where: 'id = ?',
      whereArgs: [workoutExercise.id],
    );
  }
}
