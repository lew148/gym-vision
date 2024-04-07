import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/user_exercise_details_helper.dart';
import 'package:gymvision/db/helpers/workout_exercise_orderings_helper.dart';
import 'package:gymvision/globals.dart';
import 'package:sqflite/sqflite.dart';

import '../../enums.dart';
import '../classes/exercise.dart';
import '../classes/workout_set.dart';
import '../db.dart';

class WorkoutSetsHelper {
  static Future<List<WorkoutSet>?> getWorkoutSetsForWorkout(int workoutId) async =>
      await getWorkoutSets(whereStr: 'workoutId = $workoutId');

  static Future<List<WorkoutSet>?> getWorkoutSetsForExercise(int exerciseId) async =>
      await getWorkoutSets(whereStr: 'exerciseId = $exerciseId');

  static Future<WorkoutSet?> getWorkoutSet({required int id, bool shallow = false}) async {
    var sets = await getWorkoutSets(whereStr: 'id = $id', shallow: shallow);
    return sets.isNotEmpty ? sets.first : null;
  }

  static Future<List<WorkoutSet>> getWorkoutSets({
    String? whereStr,
    bool shallow = false,
  }) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.workoutId,
        workout_sets.exerciseId,
        workout_sets.done,
        workout_sets.weight,
        workout_sets.reps,
        workout_sets.time,
        workout_sets.distance,
        workout_sets.calsBurned,
        workouts.date,
        exercises.name,
        exercises.exerciseType,
        exercises.muscleGroup,
        exercises.equipment,
        exercises.split,
        exercises.isDouble
      FROM workout_sets
      LEFT JOIN workouts ON workout_sets.workoutId = workouts.id
      LEFT JOIN exercises ON workout_sets.exerciseId = exercises.id
      ${whereStr == null ? '' : 'WHERE workout_sets.$whereStr'};
    ''');

    List<WorkoutSet> sets = [];
    for (var map in maps) {
      sets.add(WorkoutSet(
        id: map['id'],
        workoutId: map['workoutId'],
        exerciseId: map['exerciseId'],
        done: map['done'] == 1,
        weight: map['weight'],
        reps: map['reps'],
        time: tryParseDuration(map['time']),
        distance: map['distance'],
        calsBurned: map['calsBurned'],
        workout: Workout(date: DateTime.parse(map['date'])),
        exercise: !shallow
            ? Exercise(
                id: map['exerciseId'],
                name: map['name'],
                muscleGroup: MuscleGroup.values.elementAt(map['muscleGroup']),
                exerciseType: ExerciseType.values.elementAt(map['exerciseType']),
                equipment: ExerciseEquipment.values.elementAt(map['equipment']),
                split: ExerciseSplit.values.elementAt(map['split']),
                isDouble: map['isDouble'] == 1,
                userExerciseDetails: await UserExerciseDetailsHelper.getUserDetailsForExercise(
                  exerciseId: map['exerciseId'],
                  includeRecentUses: false,
                  existingDb: db,
                ),
              )
            : null,
      ));
    }

    return sets;
  }

  static addSetToWorkout(WorkoutSet ws) async {
    final db = await DatabaseHelper.getDb();
    final ordering = await WorkoutExerciseOrderingsHelper.getWorkoutExerciseOrderingForWorkout(ws.workoutId);

    await db.insert(
      'workout_sets',
      ws.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (ordering != null && !ordering.getPositions().contains(ws.exerciseId)) {
      final newOrder = ordering.getPositions();
      newOrder.add(ws.exerciseId);
      ordering.setPositions(newOrder);
      await WorkoutExerciseOrderingsHelper.updateWorkoutExerciseOrdering(ordering);
    }
  }

  static removeSet(int setId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  static updateWorkoutSet(WorkoutSet workoutSet) async {
    final db = await DatabaseHelper.getDb();
    await db.update(
      'workout_sets',
      workoutSet.toMap(),
      where: 'id = ?',
      whereArgs: [workoutSet.id],
    );
  }

  static removegroupedSetsFromWorkout(int workoutId, int exerciseId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_sets',
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );

    await WorkoutExerciseOrderingsHelper.removeExerciseFromOrderingForWorkout(workoutId, exerciseId);
  }

  static Future<WorkoutSet?> getPr({required int exerciseId, Database? existingDb}) async {
    final db = await DatabaseHelper.getDb(existingDb: existingDb);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      WITH max_table AS (
        SELECT
          workout_sets.id,
          workout_sets.workoutId,
          workout_sets.exerciseId,
          workout_sets.done,
          workout_sets.weight,
          workout_sets.reps,
          workouts.date
        FROM workout_sets
        LEFT JOIN workouts ON workout_sets.workoutId = workouts.id
        INNER JOIN (
          SELECT MAX(workout_sets.weight) AS max_weight
          FROM workout_sets
          WHERE workout_sets.exerciseId = $exerciseId
        ) AS b ON workout_sets.weight = b.max_weight
        WHERE NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
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

    final set = maps[0];
    return WorkoutSet(
      id: set['id'],
      workoutId: set['workoutId'],
      exerciseId: set['exerciseId'],
      done: set['done'] == 1,
      weight: set['weight'],
      reps: set['reps'],
      workout: Workout(date: DateTime.parse(set['date'])),
    );
  }

  static Future<WorkoutSet?> getLast({required int exerciseId, Database? existingDb}) async {
    final db = await DatabaseHelper.getDb(existingDb: existingDb);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.workoutId,
        workout_sets.exerciseId,
        workout_sets.done,
        workout_sets.weight,
        workout_sets.reps,
        workouts.date
      FROM workout_sets
      LEFT JOIN workouts ON workout_sets.workoutId = workouts.id
      WHERE workout_sets.exerciseId = $exerciseId AND NOT (workout_sets.weight = 0.0 AND workout_sets.reps = 0)
      ORDER BY workout_sets.lastUpdated DESC
      LIMIT 1;
    ''');

    if (maps.isEmpty) return null;

    final set = maps[0];
    return WorkoutSet(
      id: set['id'],
      workoutId: set['workoutId'],
      exerciseId: exerciseId,
      done: set['done'] == 1,
      weight: set['weight'],
      reps: set['reps'],
      workout: Workout(date: DateTime.parse(set['date'])),
    );
  }
}
