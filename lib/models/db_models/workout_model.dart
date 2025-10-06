import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/note_model.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutModel {
  static Future<List<Workout>> getWorkoutsForDay(DateTime date, {bool withSummary = false}) async {
    const maxWorkoutsForSummaryCalc = 3;
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

    if (withSummary) {
      for (final workout in workouts) {
        workout.summary = await getWorkoutSummary(
          workout: workout,
          fullSummary: workouts.length <= maxWorkoutsForSummaryCalc,
        );
      }
    }

    return workouts;
  }

  // prioritises workout over id
  static Future<WorkoutSummary?> getWorkoutSummary({int? id, Workout? workout, bool fullSummary = true}) async {
    if (workout == null && id != null) {
      workout = await getWorkout(id, withExercises: true);
    }

    if (workout == null) return null;

    final summary = WorkoutSummary(
      note: (await NoteModel.getNoteForObject(NoteType.workout, workout.id.toString()))?.note,
    );

    if (workout.workoutExercises == null || workout.workoutExercises!.isEmpty) return summary;

    final allSets = [for (var we in workout.getWorkoutExercises()) ...we.getSets()];
    allSets.removeWhere((s) => !s.done);
    summary.totalExercises = workout.getWorkoutExercises().length;
    summary.totalSets = allSets.length;
    summary.totalReps = allSets.map((s) => s.reps ?? 0).sum;
    summary.totalCalsBurned = allSets.map((s) => s.calsBurned ?? 0).sum;

    if (!fullSummary || allSets.isEmpty) return summary;

    WorkoutSet? bestSet;
    final setsGroupedByWeight = groupBy(allSets, (s) => s.weight);
    final heaviestWeight = (setsGroupedByWeight.keys.toList()..sort((a, b) => a! < b! ? 1 : 0)).first;
    final bestSets = setsGroupedByWeight[heaviestWeight];
    if (bestSets != null) {
      if (bestSets.length > 1) {
        var bestSetsGroupedByReps = groupBy(bestSets, (s) => s.reps);
        var highestReps = (bestSetsGroupedByReps.keys.toList()..sort((a, b) => a! < b! ? 1 : 0)).first;
        bestSet = bestSetsGroupedByReps[highestReps]?.first;
      } else {
        bestSet = bestSets.first;
      }
    }

    if (bestSet != null) {
      final we = workout.getWorkoutExercises().firstWhere((we) => we.id == bestSet!.workoutExerciseId);
      summary.bestSetExercise = DefaultExercisesModel.getExerciseByIdentifier(we.exerciseIdentifier);
    }

    summary.bestSet = bestSet;
    return summary;
  }

  static Future<List<Workout>> getAllWorkouts({
    bool withSummary = false,
    List<Category>? filterCategories,
    DateTime? date,
  }) async {
    final db = DatabaseHelper.db;

    var query = db.select(db.driftWorkouts).join(
        [leftOuterJoin(db.driftWorkoutCategories, db.driftWorkoutCategories.workoutId.equalsExp(db.driftWorkouts.id))])
      ..orderBy([OrderingTerm.desc(db.driftWorkouts.date)]);

    if (filterCategories != null && filterCategories.isNotEmpty) {
      query = query..where(db.driftWorkoutCategories.category.isInValues(filterCategories));
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
        ..where(db.driftWorkouts.date.isBiggerOrEqualValue(startOfDay))
        ..where(db.driftWorkouts.date.isSmallerThanValue(endOfDay));
    }

    final workouts =
        (await (query).map((row) => row.readTable(db.driftWorkouts)).get()).map((w) => w.toObject()).toList();

    await Future.wait(workouts.map((workout) async {
      workout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(workout.id!);
      if (withSummary) {
        workout.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(workout.id!, withSets: true);
        workout.summary = await getWorkoutSummary(workout: workout);
      }
    }));

    return workouts;
  }

  static Future<Workout?> getActiveWorkout({bool withCategories = false, bool withWorkoutExercises = false}) async {
    const maxHoursToLook = 4;
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    final lowerBound = now.add(const Duration(hours: -maxHoursToLook));

    var activeWorkout = (await (db.select(db.driftWorkouts)
              ..orderBy([(w) => OrderingTerm.desc(w.date)])
              ..where((w) => w.date.isSmallerThanValue(now))
              ..where((w) => w.date.isBiggerThanValue(lowerBound))
              ..where((w) => w.endDate.isNull())
              ..limit(1))
            .getSingleOrNull())
        ?.toObject();

    if (activeWorkout == null) {
      final upperBound = now.add(const Duration(hours: maxHoursToLook));
      activeWorkout = (await (db.select(db.driftWorkouts)
                ..orderBy([(w) => OrderingTerm.desc(w.date)])
                ..where((w) => w.date.isBiggerThanValue(now))
                ..where((w) => w.date.isSmallerThanValue(upperBound))
                ..where((w) => w.endDate.isNull())
                ..limit(1))
              .getSingleOrNull())
          ?.toObject();
    }

    if (activeWorkout == null) return null;

    if (withCategories) {
      activeWorkout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(activeWorkout.id!);
    }

    if (withWorkoutExercises) {
      activeWorkout.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(
        activeWorkout.id!,
        withSets: true,
      );
    }

    return activeWorkout;
  }

  static Future<Workout?> getWorkout(
    int id, {
    bool withCategories = false,
    bool withExercises = false,
    bool withSummary = false,
  }) async {
    final db = DatabaseHelper.db;
    final workout = (await (db.select(db.driftWorkouts)..where((w) => w.id.equals(id))).getSingleOrNull())?.toObject();
    if (workout == null) return null;

    if (withCategories) {
      workout.workoutCategories = await WorkoutCategoryModel.getWorkoutCategoriesByWorkout(workout.id!);
    }

    // summary requires exercises
    if (withExercises || withSummary) {
      workout.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(workout.id!, withSets: true);
    }

    if (withSummary) {
      workout.summary = await getWorkoutSummary(workout: workout);
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
          ..orderBy([OrderingTerm.desc(db.driftWorkouts.date)])
          ..where(db.driftWorkoutCategories.category.equalsValue(wc.category))
          ..where(db.driftWorkouts.date.isSmallerThanValue(workout.date))
          ..limit(1))
        .map((row) => row.readTable(db.driftWorkouts).id)
        .getSingleOrNull());
  }

  static Future<bool> copyLastSimilarWorkout(int workoutId, List<Category> categories) async {
    try {
      final db = DatabaseHelper.db;
      var currentWorkout = await getWorkout(workoutId);
      if (currentWorkout == null) return false;

      const maxWorkoutsToLoad = 50;
      final workouts = await (db.select(db.driftWorkouts)
            ..where((w) => w.date.isSmallerThanValue(currentWorkout.date))
            ..orderBy([(w) => OrderingTerm.desc(w.date)])
            ..limit(maxWorkoutsToLoad))
          .get();

      for (final workout in workouts) {
        final wcs = await (db.select(db.driftWorkoutCategories)..where((wc) => wc.workoutId.equals(workout.id))).get();
        final categoryList = wcs.map((wc) => wc.category).whereType<Category>().toSet();
        if (categoryList.length != categories.length || !categoryList.containsAll(categories)) continue;
        return await copyWorkout(currentWorkout, workout.toObject());
      }
    } catch (ex) {
      // ignore
    }

    return false;
  }

  static Future<bool> copyLastWorkout(int workoutId) async {
    try {
      final db = DatabaseHelper.db;
      var currentWorkout = await getWorkout(workoutId);
      if (currentWorkout == null) return false;

      final lastWorkout = (await (db.select(db.driftWorkouts)
                ..orderBy([(w) => OrderingTerm.desc(w.date)])
                ..where((w) => db.driftWorkouts.date.isSmallerThanValue(currentWorkout.date))
                ..limit(1))
              .getSingleOrNull())
          ?.toObject();

      return lastWorkout == null ? false : await copyWorkout(currentWorkout, lastWorkout);
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> copyWorkout(Workout workout, Workout workoutToCopy) async {
    try {
      if (workout.id == null) return false;

      var toCopyWes = workoutToCopy.getWorkoutExercises();
      if (toCopyWes.isEmpty) {
        workoutToCopy.workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesByWorkout(
          workoutToCopy.id!,
          withSets: true,
        );

        toCopyWes = workoutToCopy.getWorkoutExercises();
      }

      if (toCopyWes.isEmpty) return false;

      for (var toCopyWeId in OrderingHelper.getOrderingIntList(workoutToCopy.exerciseOrder)) {
        final toCopyWe = toCopyWes.firstWhereOrNull((we) => we.id == toCopyWeId);
        if (toCopyWe == null) continue;

        final newWe = WorkoutExercise(
          workoutId: workout.id!,
          exerciseIdentifier: toCopyWe.exerciseIdentifier,
          setOrder: '',
        );

        newWe.id = await WorkoutExerciseModel.insert(newWe);
        if (newWe.id == -1) continue;

        final toCopySets = toCopyWe.getSets();
        if (toCopySets.isEmpty) continue;

        for (var toCopySetId in OrderingHelper.getOrderingIntList(toCopyWe.setOrder)) {
          final toCopySet = toCopySets.firstWhereOrNull((s) => s.id == toCopySetId);
          if (toCopySet == null) continue;

          await WorkoutSetModel.insert(WorkoutSet(
            workoutExerciseId: newWe.id!,
            weight: toCopySet.weight,
            reps: toCopySet.reps,
            time: toCopySet.time,
            distance: toCopySet.distance,
            calsBurned: toCopySet.calsBurned,
          ));
        }
      }

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<String?> getWorkoutExportString(int id) async => '';

  static Future<bool> importWorkout(String s) async => true;
}
