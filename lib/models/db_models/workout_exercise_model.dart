import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/db/custom_database.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutExerciseModel {
  static Future<WorkoutExercise?> getWorkoutExercise(int workoutExerciseId, [CustomDatabase? db]) async {
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
      setOrder: maps.first['setOrder'],
    );
  }

  static Future<WorkoutExercise?> getWorkoutExerciseByWorkoutAndExercise(
    int workoutId,
    String exerciseIdentifier,
  ) async {
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
      setOrder: maps.first['setOrder'],
    );
  }

  static Future deleteWorkoutExercise(int workoutExerciseId, {CustomDatabase? db}) async {
    db ??= await DatabaseHelper.getDb();

    var workoutExercise = await getWorkoutExercise(workoutExerciseId, db);
    if (workoutExercise == null) return;

    final workout = await WorkoutModel.getWorkout(workoutId: workoutExercise.workoutId);
    if (workout == null) return false;
    workout.exerciseOrder = OrderingHelper.removeFromOrdering(workout.exerciseOrder, workoutExerciseId);
    await WorkoutModel.updateWorkout(workout);

    await db.delete(
      'workout_sets',
      where: 'workoutExerciseId = ?',
      whereArgs: [workoutExerciseId],
    );

    await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [workoutExerciseId],
    );
  }

  static Future<List<WorkoutExercise>> getWorkoutExercisesForWorkout(int workoutId, {CustomDatabase? db}) async {
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
        setOrder: m['setOrder'],
      ));
    }

    return workoutExercises;
  }

  static Future<int> insertWorkoutExercise(WorkoutExercise workoutExercise) async {
    var db = await DatabaseHelper.getDb();
    final workout = await WorkoutModel.getWorkout(workoutId: workoutExercise.workoutId);
    if (workout == null) return -1;

    final now = DateTime.now();
    workoutExercise.updatedAt = now;
    workoutExercise.createdAt = now;
    final newWorkoutExerciseId = await db.insert(
      'workout_exercises',
      workoutExercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    workout.exerciseOrder = OrderingHelper.addToOrdering(workout.exerciseOrder, newWorkoutExerciseId);
    await WorkoutModel.updateWorkout(workout);

    return newWorkoutExerciseId;
  }

  static Future<bool> updateWorkoutExercise(WorkoutExercise workoutExercise) async {
    final db = await DatabaseHelper.getDb();
    workoutExercise.updatedAt = DateTime.now();
    await db.update(
      'workout_exercises',
      workoutExercise.toMap(),
      where: 'id = ?',
      whereArgs: [workoutExercise.id],
    );
    return true;
  }

  static Future<bool> markAllSetsDone(int id, bool done) async {
    try {
      final sets = await WorkoutSetModel.getWorkoutSets(whereStr: 'workoutExerciseId = $id');
      for (var set in sets) {
        set.done = done;
        await WorkoutSetModel.updateWorkoutSet(set);
      }

      return true;
    } catch (ex) {
      return false;
    }
  }
}
