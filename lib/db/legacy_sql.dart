import 'package:collection/collection.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/db/helpers/user_exercise_details_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';
import 'package:sqflite/sqflite.dart';

class LegacySql {
  static Future<List<Workout>> getWorkoutsLegacy() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        workouts.id,
        workouts.date,
        workout_categories.id AS workoutCategoryId,
        workout_categories.categoryShellId
      FROM workouts
      LEFT JOIN workout_categories ON workouts.id = workout_categories.workoutId
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

    for (var w in workouts) {
      w.done = await workoutIsDone(workoutId: w.id!, db: db);
    }

    return workouts;
  }

  static List<WorkoutCategory>? processWorkoutCategories(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;

    List<WorkoutCategory> workoutCategories = [];
    for (var m in list) {
      final workoutCategoryId = m['workoutCategoryId'];
      if (workoutCategoryId == null) continue;

      workoutCategories.add(
        WorkoutCategory(id: workoutCategoryId, workoutId: m['id'], categoryShellId: m['categoryShellId']),
      );
    }
    return workoutCategories;
  }

  static Future<bool> workoutIsDone({required int workoutId, Database? db}) async {
    db ??= await DatabaseHelper.getDb();
    int? noIncompleteSets = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*)
      FROM workout_sets
      WHERE workoutId = $workoutId AND done = 0;
    '''));

    if (noIncompleteSets == null) return false;
    return noIncompleteSets == 0;
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

  static Future<List<Bodyweight>> getBodyweights() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('bodyweights');

    List<Bodyweight> bws = [];
    for (var map in maps) {
      bws.add(Bodyweight(
        id: map['id'],
        date: DateTime.parse(map['date']),
        weight: map['weight'],
        units: map['units'],
      ));
    }

    return bws;
  }
}
