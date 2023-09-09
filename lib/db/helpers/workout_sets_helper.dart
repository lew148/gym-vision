import 'package:gymvision/db/classes/user_exercise_details.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/user_exercise_details_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../enums.dart';
import '../classes/exercise.dart';
import '../classes/workout_set.dart';
import '../db.dart';

class WorkoutSetsHelper {
  static Future<List<WorkoutSet>?> getWorkoutSetsForWorkout(int workoutId) async =>
      await getWorkoutSets(whereProp: 'workoutId', value: workoutId);

  static Future<List<WorkoutSet>?> getWorkoutSetsForExercise(int exerciseId) async =>
      await getWorkoutSets(whereProp: 'exerciseId', value: exerciseId);

  static Future<WorkoutSet?> getWorkoutSet({required int id, bool shallow = false}) async {
    var sets = await getWorkoutSets(whereProp: 'id', value: id, shallow: shallow);
    return sets.isNotEmpty ? sets.first : null;
  }

  static Future<List<WorkoutSet>> getWorkoutSets({
    required String whereProp,
    required int value,
    bool shallow = false,
  }) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workout_sets.id,
        workout_sets.workoutId,
        workout_sets.exerciseId,
        workout_sets.done,
        workout_sets.weight,
        workout_sets.reps,
        workouts.date,
        exercises.name,
        exercises.exerciseType,
        exercises.muscleGroup,
        exercises.equipment,
        exercises.split,
        exercises.isDouble,
        exercises.isCustom,
        user_exercise_details.id AS userExerciseDetailsId,
        user_exercise_details.notes,
        user_exercise_details.prId,
        user_exercise_details.lastId
      FROM workout_sets
      LEFT JOIN workouts ON workout_sets.workoutId = workouts.id
      LEFT JOIN exercises ON workout_sets.exerciseId = exercises.id
      LEFT JOIN user_exercise_details ON exercises.id = user_exercise_details.exerciseId
      WHERE workout_sets.$whereProp = $value;
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
        workout: Workout(date: DateTime.parse(map['date'])),
        exercise: !shallow
            ? Exercise(
                id: map['exerciseId'],
                name: map['name'],
                muscleGroup: MuscleGroup.values.elementAt(map['muscleGroup']),
                equipment: ExerciseEquipment.values.elementAt(map['equipment']),
                split: ExerciseSplit.values.elementAt(map['split']),
                isDouble: map['isDouble'] == 1,
                isCustom: map['isCustom'] == 1,
                userExerciseDetails: map['userExerciseDetailsId'] == null
                    ? null
                    : UserExerciseDetails(
                        id: map['userExerciseDetailsId'],
                        exerciseId: map['exerciseId'],
                        notes: map['notes'],
                        pr: map['prId'] != null
                            ? await WorkoutSetsHelper.getWorkoutSet(id: map['prId'], shallow: true)
                            : null,
                        last: map['lastId'] != null
                            ? await WorkoutSetsHelper.getWorkoutSet(id: map['lastId'], shallow: true)
                            : null,
                      ),
              )
            : null,
      ));
    }

    return sets;
  }

  static addSetToWorkout({
    required int exerciseId,
    required int workoutId,
    double? weight,
    int? reps,
    bool? done,
  }) async {
    final db = await DatabaseHelper().getDb();

    var setId = await db.insert(
      'workout_sets',
      WorkoutSet(
        workoutId: workoutId,
        exerciseId: exerciseId,
        weight: weight ?? 0,
        reps: reps ?? 0,
        done: done ?? false,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (weight == null) return;

    final details = await UserExerciseDetailsHelper.getUserDetailsForExercise(exerciseId, false);
    if (details == null) {
      await UserExerciseDetailsHelper.insertUserExerciseDetails(UserExerciseDetails(
        exerciseId: exerciseId,
        prId: setId,
        lastId: setId,
      ));
    } else {
      if (details.pr == null || details.pr!.weight! < weight) {
        details.prId = setId;
      }

      details.lastId = setId;
      await UserExerciseDetailsHelper.updateUserExerciseDetails(details);
    }
  }

  static removeSet(int setId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  static updateWorkoutSet(WorkoutSet workoutSet) async {
    final db = await DatabaseHelper().getDb();
    await db.update(
      'workout_sets',
      workoutSet.toMap(),
      where: 'id = ?',
      whereArgs: [workoutSet.id],
    );
  }

  static removegroupedSetsFromWorkout(int workoutId, int exerciseId) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'workout_sets',
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
  }
}
