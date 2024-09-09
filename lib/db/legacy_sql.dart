import 'package:collection/collection.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/db.dart';
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
    return noIncompleteSets == 0;
  }

  static Future<List<WorkoutSet>> getWorkoutSets() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('workout_sets');

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
