import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_set.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';

class WorkoutTemplateModel {
  // gets
  static Future<List<WorkoutTemplate>> getAll({bool withExercises = false}) async {
    final db = DatabaseHelper.db;

    var workoutTemplates =
        (await (db.select(db.driftWorkoutTemplates)..orderBy([(wt) => OrderingTerm.desc(wt.createdAt)])).get())
            .map((wt) => wt.toObject())
            .toList();

    if (withExercises) {
      for (final wt in workoutTemplates) {
        wt.workoutTemplateExercises = await getWorkoutTemplateExercisesForWorkoutTemplate(wt.id!);
      }
    }

    return workoutTemplates;
  }

  static Future<List<WorkoutTemplateExercise>> getWorkoutTemplateExercisesForWorkoutTemplate(
    int workoutTemplateId,
  ) async {
    final db = DatabaseHelper.db;

    var workoutTemplateExercises = (await (db.select(db.driftWorkoutTemplateExercises)
              ..where((wte) => wte.workoutTemplateId.equals(workoutTemplateId)))
            .get())
        .map((wte) => wte.toObject())
        .toList();

    for (final wte in workoutTemplateExercises) {
      wte.workoutTemplateSets = await getWorkoutTemplateSetsForWorkoutTemplateExercise(wte.id!);
    }

    return workoutTemplateExercises;
  }

  static Future<List<WorkoutTemplateSet>> getWorkoutTemplateSetsForWorkoutTemplateExercise(
    int workoutTemplateExerciseId,
  ) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutTemplateSets)
              ..where((wts) => wts.workoutTemplateExerciseId.equals(workoutTemplateExerciseId)))
            .get())
        .map((wts) => wts.toObject())
        .toList();
  }

  // inserts
  static Future<int> insert(WorkoutTemplate workoutTemplate) async {
    final db = DatabaseHelper.db;
    var now = DateTime.now();
    return await db.into(db.driftWorkoutTemplates).insert(DriftWorkoutTemplatesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          name: workoutTemplate.name,
          categories: workoutTemplate.categories,
          exerciseOrder: workoutTemplate.exerciseOrder,
        ));
  }

  static Future<int> insertWorkoutTemplateExercise(WorkoutTemplateExercise workoutTemplateExercise) async {
    final db = DatabaseHelper.db;
    var now = DateTime.now();
    return await db.into(db.driftWorkoutTemplateExercises).insert(DriftWorkoutTemplateExercisesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutTemplateId: workoutTemplateExercise.workoutTemplateId,
          exerciseIdentifier: workoutTemplateExercise.exerciseIdentifier,
          setOrder: workoutTemplateExercise.setOrder,
        ));
  }

  static Future<int> insertWorkoutTemplateSet(WorkoutTemplateSet workoutTemplateSet) async {
    final db = DatabaseHelper.db;
    var now = DateTime.now();
    return await db.into(db.driftWorkoutTemplateSets).insert(DriftWorkoutTemplateSetsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutTemplateExerciseId: workoutTemplateSet.workoutTemplateExerciseId,
          weight: Value(workoutTemplateSet.weight),
          reps: Value(workoutTemplateSet.reps),
          time: Value(workoutTemplateSet.time),
          distance: Value(workoutTemplateSet.distance),
          calsBurned: Value(workoutTemplateSet.calsBurned),
        ));
  }

  // updates
  static Future<bool> update(WorkoutTemplate workoutTemplate) async {
    final db = DatabaseHelper.db;
    if (workoutTemplate.id == null) return false;

    await (db.update(db.driftWorkoutTemplates)..where((w) => w.id.equals(workoutTemplate.id!)))
        .write(DriftWorkoutTemplatesCompanion(
      updatedAt: Value(DateTime.now()),
      name: Value(workoutTemplate.name),
      categories: Value(workoutTemplate.categories),
      exerciseOrder: Value(workoutTemplate.exerciseOrder),
    ));

    return true;
  }

  static Future<bool> updateWorkoutTemplateExercise(WorkoutTemplateExercise workoutTemplateExercise) async {
    final db = DatabaseHelper.db;
    if (workoutTemplateExercise.id == null) return false;

    await (db.update(db.driftWorkoutTemplateExercises)..where((w) => w.id.equals(workoutTemplateExercise.id!)))
        .write(DriftWorkoutTemplateExercisesCompanion(
      updatedAt: Value(DateTime.now()),
      setOrder: Value(workoutTemplateExercise.setOrder),
    ));

    return true;
  }

  static Future<bool> updateWorkoutTemplateSet(WorkoutTemplateSet workoutTemplateSet) async {
    final db = DatabaseHelper.db;
    if (workoutTemplateSet.id == null) return false;

    await (db.update(db.driftWorkoutTemplateSets)..where((w) => w.id.equals(workoutTemplateSet.id!)))
        .write(DriftWorkoutTemplateSetsCompanion(
      updatedAt: Value(DateTime.now()),
      weight: Value(workoutTemplateSet.weight),
      reps: Value(workoutTemplateSet.reps),
      time: Value(workoutTemplateSet.time),
      distance: Value(workoutTemplateSet.distance),
      calsBurned: Value(workoutTemplateSet.calsBurned),
    ));

    return true;
  }

  // deletes
  static Future<bool> delete(int workoutTemplateId) async {
    final db = DatabaseHelper.db;

    final wtes = await getWorkoutTemplateExercisesForWorkoutTemplate(workoutTemplateId);
    for (var wte in wtes) {
      await deleteWorkoutTemplateExercise(wte.id!);
    }

    await (db.delete(db.driftWorkoutTemplates)..where((wt) => wt.id.equals(workoutTemplateId))).go();
    return true;
  }

  static Future<bool> deleteWorkoutTemplateExercise(int workoutTemplateExerciseId) async {
    final db = DatabaseHelper.db;

    final sets = await getWorkoutTemplateSetsForWorkoutTemplateExercise(workoutTemplateExerciseId);
    for (final set in sets) {
      await (db.delete(db.driftWorkoutTemplateSets)..where((wts) => wts.id.equals(set.id!))).go();
    }

    await (db.delete(db.driftWorkoutTemplateExercises)..where((wte) => wte.id.equals(workoutTemplateExerciseId))).go();
    return true;
  }
}
