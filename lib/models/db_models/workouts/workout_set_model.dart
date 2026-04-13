import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutSetModel {
  static Future<List<WorkoutSet>> getSetsForWorkoutExercise(int workoutExerciseId, {String? exerciseIdentifier}) async {
    final db = DatabaseHelper.db;

    final sets =
        (await (db.select(db.driftWorkoutSets)..where((ws) => ws.workoutExerciseId.equals(workoutExerciseId))).get())
            .map((ws) => ws.toObject())
            .toList();

    if (exerciseIdentifier == null) return sets;

    final allSets = await getSetsForExercise(exerciseIdentifier);
    final pr = await getPR(exerciseIdentifier, sets: allSets);
    final first = await getFirst(exerciseIdentifier, sets: allSets);
    final isCardio = DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier)?.type == ExerciseType.cardio;

    for (final set in sets) {
      set.setInfo(pr: isCardio ? null : pr, first: first);
    }

    return sets;
  }

  static Future<WorkoutSet?> getSet(int id) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutSets)..where((ws) => ws.id.equals(id))).getSingleOrNull())?.toObject();
  }

  static Future<int> insert(WorkoutSet set) async {
    final workoutExercise = await WorkoutExerciseModel.getWorkoutExercise(set.workoutExerciseId);
    if (workoutExercise == null) return -1;

    final db = DatabaseHelper.db;
    var now = DateTime.now();
    final setId = await db.into(db.driftWorkoutSets).insert(DriftWorkoutSetsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutExerciseId: workoutExercise.id!,
          weight: Value(set.weight),
          addedWeight: Value(set.addedWeight),
          assistedWeight: Value(set.assistedWeight),
          reps: Value(set.reps),
          time: Value(set.time),
          distance: Value(set.distance),
          calsBurned: Value(set.calsBurned),
          done: Value(set.done),
        ));

    workoutExercise.setOrder = OrderingHelper.addToOrdering(workoutExercise.setOrder, setId);
    await WorkoutExerciseModel.update(workoutExercise);
    return setId;
  }

  static Future<bool> update(WorkoutSet set) async {
    if (set.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftWorkoutSets)..where((s) => s.id.equals(set.id!))).write(DriftWorkoutSetsCompanion(
      updatedAt: Value(DateTime.now()),
      weight: Value(set.weight),
      addedWeight: Value(set.addedWeight),
      assistedWeight: Value(set.assistedWeight),
      reps: Value(set.reps),
      time: Value(set.time),
      distance: Value(set.distance),
      calsBurned: Value(set.calsBurned),
      done: Value(set.done),
    ));

    return true;
  }

  static Future<bool> delete(int id) async {
    final set = await getSet(id);
    if (set == null) return false;

    final workoutExercise = await WorkoutExerciseModel.getWorkoutExercise(set.workoutExerciseId);
    if (workoutExercise == null) return false;

    final db = DatabaseHelper.db;
    final deletedRows = await (db.delete(db.driftWorkoutSets)..where((s) => s.id.equals(id))).go();
    if (deletedRows == 0) return false;

    workoutExercise.setOrder = OrderingHelper.removeFromOrdering(workoutExercise.setOrder, id);
    await WorkoutExerciseModel.update(workoutExercise);
    return true;
  }

  static Future<List<WorkoutSet>> getSetsForExercise(String exerciseIdentifier) async {
    final List<WorkoutSet> sets = [];
    final workoutExercises = await WorkoutExerciseModel.getWorkoutExercisesForExercise(
      exerciseIdentifier,
      withSets: true,
      withWorkout: true,
    );

    for (final we in workoutExercises) {
      sets.addAll((await WorkoutSetModel.getSetsForWorkoutExercise(we.id!)).map((s) {
        s.workoutExercise = we;
        return s;
      }));
    }

    return sets;
  }

  static Future<WorkoutSet?> getPR(String exerciseIdentifier, {List<WorkoutSet>? sets}) async {
    final allSets = await getSetsForExercise(exerciseIdentifier);
    allSets.removeWhere((s) => !s.done);
    if (allSets.isEmpty) return null;

    // sort by weight descending and remove lower weights
    allSets.sort((a, b) => (b.weight ?? 0).compareTo((a.weight ?? 0)));
    final heaviestWeight = allSets.first.weight;
    allSets.removeWhere((s) => s.weight != heaviestWeight);

    // sort by reps descending and remove lower reps
    allSets.sort((a, b) => b.reps!.compareTo(a.reps!));
    final mostReps = allSets.first.reps;
    allSets.removeWhere((s) => s.reps != mostReps);

    // sort by createdAt descending
    allSets.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    return allSets.firstOrNull;
  }

  static Future<WorkoutSet?> getLast(String exerciseIdentifier, {List<WorkoutSet>? sets}) async {
    final allSets = await getSetsForExercise(exerciseIdentifier);
    allSets.removeWhere((s) => !s.done);
    allSets.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return allSets.firstOrNull;
  }

  static Future<WorkoutSet?> getFirst(String exerciseIdentifier, {List<WorkoutSet>? sets}) async {
    final allSets = sets ?? await getSetsForExercise(exerciseIdentifier);
    allSets.removeWhere((s) => !s.done);
    allSets.sort((a, b) => a.updatedAt!.compareTo(b.updatedAt!));
    return allSets.firstOrNull;
  }
}
