import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';

class WorkoutSetModel {
  static Future<List<WorkoutSet>> getSetsForWorkoutExercise(int workoutExerciseId) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutSets)..where((ws) => ws.workoutExerciseId.equals(workoutExerciseId))).get())
        .map((ws) => ws.toObject())
        .toList();
  }

  static Future<WorkoutSet?> getSet(int id) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutSets)..where((ws) => ws.id.equals(id))).getSingleOrNull())?.toObject();
  }

  static Future insert(WorkoutSet set) async {
    final workoutExercise = await WorkoutExerciseModel.getWorkoutExercise(set.workoutExerciseId);
    if (workoutExercise == null) return;

    final db = DatabaseHelper.db;
    var now = DateTime.now();
    final setId = await db.into(db.driftWorkoutSets).insert(DriftWorkoutSetsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutExerciseId: workoutExercise.id!,
          weight: Value(set.weight),
          reps: Value(set.reps),
          time: Value(set.time),
          distance: Value(set.distance),
          calsBurned: Value(set.calsBurned),
          done: Value(set.done),
        ));

    workoutExercise.setOrder = OrderingHelper.addToOrdering(workoutExercise.setOrder, setId);
    await WorkoutExerciseModel.update(workoutExercise);
  }

  static Future<bool> update(WorkoutSet set) async {
    if (set.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftWorkoutSets)..where((s) => s.id.equals(set.id!))).write(DriftWorkoutSetsCompanion(
      updatedAt: Value(DateTime.now()),
      weight: Value(set.weight),
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
}
