import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';

class WorkoutModel {
  static Future<List<Workout>> getWorkoutsForDay(DateTime date) async {
    final db = DatabaseHelper.db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final workouts = (await (db.select(db.driftWorkouts)
              ..orderBy([(w) => OrderingTerm(expression: w.date, mode: OrderingMode.desc)])
              ..where((w) => w.date.isBiggerOrEqualValue(startOfDay))
              ..where((w) => w.date.isSmallerThanValue(endOfDay)))
            .get())
        .map((w) => w.toObject())
        .toList();

    for (final workout in workouts) {
      workout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(workout.id!);
      workout.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(workout.id!, withSets: true);
    }

    return workouts;
  }

  static Future<List<Workout>> getAllWorkouts() async {
    final db = DatabaseHelper.db;
    final workouts = (await (db.select(db.driftWorkouts)
              ..orderBy([(w) => OrderingTerm(expression: w.date, mode: OrderingMode.desc)]))
            .get())
        .map((w) => w.toObject())
        .toList();

    for (final workout in workouts) {
      workout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(workout.id!);
    }

    return workouts;
  }

  static Future<Workout?> getWorkout(int id, {bool withCategories = false, bool withWorkoutExercises = false}) async {
    final db = DatabaseHelper.db;
    final workout = (await (db.select(db.driftWorkouts)..where((w) => w.id.equals(id))).getSingleOrNull())?.toObject();
    if (workout == null) return null;

    if (withCategories) {
      workout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(workout.id!);
    }

    if (withWorkoutExercises) {
      workout.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(workout.id!, withSets: true);
    }

    return workout;
  }

  static Future<int> insert(Workout workout) async {
    final db = DatabaseHelper.db;
    var now = DateTime.now();
    return await db.into(db.driftWorkouts).insert(DriftWorkoutsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          date: workout.date,
          exerciseOrder: workout.exerciseOrder,
          endDate: Value(workout.endDate),
        ));
  }

  static Future<bool> update(Workout workout) async {
    final db = DatabaseHelper.db;
    if (workout.id == null) return false;
    await (db.update(db.driftWorkouts)..where((w) => w.id.equals(workout.id!))).write(DriftWorkoutsCompanion(
      updatedAt: Value(DateTime.now()),
      date: Value(workout.date),
      exerciseOrder: Value(workout.exerciseOrder),
      endDate: Value(workout.endDate),
    ));

    return true;
  }

  static Future<bool> delete(int workoutId) async {
    final db = DatabaseHelper.db;
    final wes = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(workoutId);
    for (var we in wes) {
      await WorkoutExerciseModel.delete(we.id!);
    }

    await (db.delete(db.driftWorkoutCategories)..where((c) => c.workoutId.equals(workoutId))).go();
    await (db.delete(db.driftWorkouts)..where((w) => w.id.equals(workoutId))).go();
    return true;
  }

  static Future<int?> getMostRecentWorkoutIdForCategory(WorkoutCategory wc) async {
    final db = DatabaseHelper.db;
    var workout = await getWorkout(wc.workoutId);
    if (workout == null) return null;
    return (await (db.select(db.driftWorkouts).join([
      leftOuterJoin(db.driftWorkoutCategories, db.driftWorkoutCategories.workoutId.equalsExp(db.driftWorkouts.id))
    ])
          ..orderBy([OrderingTerm.desc(db.driftWorkouts.id)])
          ..where(db.driftWorkoutCategories.category.equalsValue(wc.category))
          ..where(db.driftWorkoutCategories.id.isNotValue(wc.id!))
          ..where(db.driftWorkouts.date.isSmallerThanValue(workout.date))
          ..limit(1))
        .map((row) => row.readTable(db.driftWorkouts).id)
        .getSingle());
  }

  static Future<String?> getWorkoutExportString(int id) async => '';

  static Future<bool> importWorkout(String s) async => true;
}
