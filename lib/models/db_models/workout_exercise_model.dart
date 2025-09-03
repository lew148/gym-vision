import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';

class WorkoutExerciseModel {
  static Future<WorkoutExercise?> getWorkoutExercise(int id) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutExercises)..where((we) => we.id.equals(id))).getSingleOrNull())?.toObject();
  }

  static Future<WorkoutExercise?> getWorkoutExerciseByWorkoutAndExercise(
    int workoutId,
    String exerciseIdentifier,
  ) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutExercises)
              ..where((we) => we.workoutId.equals(workoutId))
              ..where((we) => we.exerciseIdentifier.equals(exerciseIdentifier)))
            .getSingleOrNull())
        ?.toObject();
  }

  static Future<List<WorkoutExercise>> getWorkoutExercisesByWorkout(int workoutId, {bool withSets = false}) async {
    final db = DatabaseHelper.db;
    final workoutExercises =
        (await (db.select(db.driftWorkoutExercises)..where((we) => we.workoutId.equals(workoutId))).get())
            .map((we) => we.toObject())
            .toList();

    if (withSets) {
      for (final we in workoutExercises) {
        we.workoutSets = await WorkoutSetModel.getSetsForWorkoutExercise(we.id!);
      }
    }

    return workoutExercises;
  }

  static Future<List<WorkoutExercise>> getWorkoutExercisesForExercise(String exerciseIdentifier) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutExercises)..where((we) => we.exerciseIdentifier.equals(exerciseIdentifier)))
            .get())
        .map((we) => we.toObject())
        .toList();
  }

  static Future<int> insert(WorkoutExercise workoutExercise) async {
    final workout = await WorkoutModel.getWorkout(workoutExercise.workoutId);
    if (workout == null) return -1;

    final db = DatabaseHelper.db;
    final now = DateTime.now();
    final id = await db.into(db.driftWorkoutExercises).insert(DriftWorkoutExercisesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutId: workout.id!,
          exerciseIdentifier: workoutExercise.exerciseIdentifier,
          setOrder: workoutExercise.setOrder,
          done: const Value(false),
        ));

    workout.exerciseOrder = OrderingHelper.addToOrdering(workout.exerciseOrder, id);
    await WorkoutModel.update(workout);
    return id;
  }

  static Future<bool> update(WorkoutExercise workoutExercise) async {
    if (workoutExercise.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftWorkoutExercises)..where((we) => we.id.equals(workoutExercise.id!)))
        .write(DriftWorkoutExercisesCompanion(
      updatedAt: Value(DateTime.now()),
      setOrder: Value(workoutExercise.setOrder),
      done: Value(workoutExercise.done),
    ));

    return true;
  }

  static Future<bool> delete(int workoutExerciseId) async {
    var workoutExercise = await getWorkoutExercise(workoutExerciseId);
    if (workoutExercise == null) return false;

    final workout = await WorkoutModel.getWorkout(workoutExercise.workoutId);
    if (workout == null) return false;
    workout.exerciseOrder = OrderingHelper.removeFromOrdering(workout.exerciseOrder, workoutExerciseId);
    await WorkoutModel.update(workout);

    final db = DatabaseHelper.db;
    await (db.delete(db.driftWorkoutSets)..where((s) => s.workoutExerciseId.equals(workoutExerciseId))).go();
    await (db.delete(db.driftWorkoutExercises)..where((we) => we.id.equals(workoutExerciseId))).go();
    return true;
  }

  static Future<bool> markAllSetsDone(int id, bool done) async {
    final db = DatabaseHelper.db;
    await (db.update(db.driftWorkoutSets)..where((s) => s.workoutExerciseId.equals(id)))
        .write(DriftWorkoutSetsCompanion(
      updatedAt: Value(DateTime.now()),
      done: Value(done),
    ));

    return true;
  }
}
