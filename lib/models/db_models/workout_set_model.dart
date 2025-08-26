import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/db/custom_database.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutSetModel {
  static Future<List<WorkoutSet>?> getWorkoutSetsForExercise(String exerciseIdentifier) async =>
      await getWorkoutSets(whereStr: ' workout_exercises.exerciseIdentifier = "$exerciseIdentifier"');

  static getWorkoutSetsForWorkoutExercise(int workoutExerciseId, CustomDatabase db) async =>
      await getWorkoutSets(whereStr: 'workout_sets.workoutExerciseId = $workoutExerciseId');

  static Future<WorkoutSet?> getWorkoutSet(int id) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('workout_sets', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    return WorkoutSet(
      id: maps.first['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(maps.first['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(maps.first['createdAt']),
      workoutExerciseId: maps.first['workoutExerciseId'],
      weight: maps.first['weight'],
      reps: maps.first['reps'],
      time: DateTimeHelper.tryParseDuration(maps.first['time']),
      distance: maps.first['distance'],
      calsBurned: maps.first['calsBurned'],
      done: maps.first['done'] == 1,
    );
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
        workout_sets.done,
        workout_sets.reps,
        workout_sets.time,
        workout_sets.distance,
        workout_sets.calsBurned,
        workout_exercises.id AS workoutExerciseId,
        workout_exercises.exerciseIdentifier,
        workout_exercises.workoutId,
        workout_exercises.done AS weDone,
        workout_exercises.setOrder,
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
          updatedAt: DateTimeHelper.tryParseDateTime(map['updatedAt']),
          createdAt: DateTimeHelper.tryParseDateTime(map['createdAt']),
          workoutExerciseId: map['workoutExerciseId'],
          weight: map['weight'],
          reps: map['reps'],
          time: DateTimeHelper.tryParseDuration(map['time']),
          distance: map['distance'],
          calsBurned: map['calsBurned'],
          done: map['done'] == 1,
          workoutExercise: WorkoutExercise(
              id: map['workoutExerciseId'],
              workoutId: map['workoutId'],
              exerciseIdentifier: map['exerciseIdentifier'],
              workout: Workout(
                id: map['workoutId'],
                date: DateTimeHelper.parseDateTime(map['date']),
              ),
              done: map['weDone'] == 1,
              setOrder: map['setOrder']),
        ),
      );
    }

    return sets;
  }

  static Future addSetToWorkout(WorkoutSet set) async {
    final db = await DatabaseHelper.getDb();
    final workoutExercise = await WorkoutExerciseModel.getWorkoutExercise(set.workoutExerciseId, db);
    if (workoutExercise == null) return;

    var now = DateTime.now();
    set.updatedAt = now;
    set.createdAt = now;
    final setId = await db.insert(
      'workout_sets',
      set.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    workoutExercise.setOrder = OrderingHelper.addToOrdering(workoutExercise.setOrder, setId);
    await WorkoutExerciseModel.updateWorkoutExercise(workoutExercise);
  }

  static Future<bool> removeSet(int setId) async {
    final db = await DatabaseHelper.getDb();
    final set = await getWorkoutSet(setId);
    if (set == null) return false;

    final workoutExercise = await WorkoutExerciseModel.getWorkoutExercise(set.workoutExerciseId, db);
    if (workoutExercise == null) return false;

    workoutExercise.setOrder = OrderingHelper.removeFromOrdering(workoutExercise.setOrder, setId);
    await WorkoutExerciseModel.updateWorkoutExercise(workoutExercise);

    await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [setId],
    );

    return true;
  }

  static Future<bool> updateWorkoutSet(WorkoutSet ws) async {
    final db = await DatabaseHelper.getDb();
    ws.updatedAt = DateTime.now();
    await db.update(
      'workout_sets',
      ws.toMap(),
      where: 'id = ?',
      whereArgs: [ws.id],
    );
    return true;
  }

  static Future<WorkoutSet?> getPr({required String exerciseIdentifier, CustomDatabase? db}) async {
    db ??= await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      WITH max_table AS (
        SELECT 
            workout_sets.id,
            workout_sets.updatedAt,
            workout_sets.createdAt,
            workout_sets.workoutExerciseId,
            workout_sets.weight,
            workout_sets.reps,
            workout_sets.time,
            workout_sets.done,
            workout_sets.distance,
            workout_sets.calsBurned,
            workout_exercises.id AS workoutExerciseId,
            workout_exercises.workoutId,
            workout_exercises.exerciseIdentifier,
            workout_exercises.done AS weDone,
            workout_exercises.setOrder,
            workouts.id AS workoutId,
            workouts.date
        FROM workout_sets
        LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
        LEFT JOIN workouts ON workout_exercises.workoutId = workouts.id
        INNER JOIN (
          SELECT MAX(workout_sets.weight) AS max_weight
          FROM workout_sets
          LEFT JOIN workout_exercises ON workout_sets.workoutExerciseId = workout_exercises.id
          WHERE workout_exercises.exerciseIdentifier = "$exerciseIdentifier" AND workout_sets.done = 1 AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
        ) AS b ON workout_sets.weight = b.max_weight
        WHERE workout_exercises.exerciseIdentifier = "$exerciseIdentifier" AND workout_sets.done = 1 AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
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
      updatedAt: DateTimeHelper.tryParseDateTime(maps.first['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(maps.first['createdAt']),
      workoutExerciseId: maps.first['workoutExerciseId'],
      done: maps.first['done'] == 1,
      weight: maps.first['weight'],
      reps: maps.first['reps'],
      time: DateTimeHelper.tryParseDuration(maps.first['time']),
      distance: maps.first['distance'],
      calsBurned: maps.first['calsBurned'],
      workoutExercise: WorkoutExercise(
        id: maps.first['workoutExerciseId'],
        workoutId: maps.first['workoutId'],
        exerciseIdentifier: maps.first['exerciseIdentifier'],
        done: maps.first['weDone'] == 1,
        setOrder: maps.first['setOrder'],
        workout: Workout(
          id: maps.first['workoutId'],
          date: DateTimeHelper.parseDateTime(maps.first['date']),
        ),
      ),
    );
  }

  static Future<WorkoutSet?> getLast({required String exerciseIdentifier, CustomDatabase? db}) async {
    db ??= await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.updatedAt,
        workout_sets.createdAt,
        workout_sets.workoutExerciseId,
        workout_sets.weight,
        workout_sets.reps,
        workout_sets.time,
        workout_sets.done,
        workout_sets.distance,
        workout_sets.calsBurned,
        workout_exercises.id AS workoutExerciseId,
        workout_exercises.workoutId,
        workout_exercises.exerciseIdentifier,
        workout_exercises.done AS weDone,
        workout_exercises.setOrder,
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
      updatedAt: DateTimeHelper.tryParseDateTime(maps.first['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(maps.first['createdAt']),
      workoutExerciseId: maps.first['workoutExerciseId'],
      weight: maps.first['weight'],
      reps: maps.first['reps'],
      time: DateTimeHelper.tryParseDuration(maps.first['time']),
      distance: maps.first['distance'],
      calsBurned: maps.first['calsBurned'],
      done: maps.first['done'] == 1,
      workoutExercise: WorkoutExercise(
        id: maps.first['workoutExerciseId'],
        workoutId: maps.first['workoutId'],
        exerciseIdentifier: maps.first['exerciseIdentifier'],
        done: maps.first['weDone'] == 1,
        setOrder: maps.first['setOrder'],
        workout: Workout(
          id: maps.first['workoutId'],
          date: DateTimeHelper.parseDateTime(maps.first['date']),
        ),
      ),
    );
  }
}
