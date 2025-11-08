import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_set.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/note_model.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutTemplateModel {
  // gets
  static Future<List<WorkoutTemplate>> getAll({
    bool withExercises = false,
    bool withNote = false,
    List<Category>? filterCategories,
  }) async {
    final db = DatabaseHelper.db;

    var query = (db.select(db.driftWorkoutTemplates)..orderBy([(wt) => OrderingTerm.desc(wt.createdAt)]));

    if (filterCategories != null && filterCategories.isNotEmpty) {
      query = query
        ..where((wt) {
          final conditions = filterCategories.map((cat) => wt.categories.like('%${EnumHelper.enumToString(cat)}%'));
          return conditions.reduce((a, b) => a | b);
        });
    }

    var workoutTemplates = (await query.get()).map((wt) => wt.toObject()).toList();

    if (withNote || withExercises) {
      for (final wt in workoutTemplates) {
        if (withNote) wt.note = await NoteModel.getNoteForObject(NoteType.template, wt.id!.toString());
        if (withExercises) wt.workoutTemplateExercises = await getExercisesForTemplate(wt.id!);
      }
    }

    return workoutTemplates;
  }

  static Future<WorkoutTemplate?> getTemplate(int id) async {
    final db = DatabaseHelper.db;

    final template =
        (await (db.select(db.driftWorkoutTemplates)..where((t) => t.id.equals(id))).getSingleOrNull())?.toObject();

    if (template == null) return null;

    template.note = await NoteModel.getNoteForObject(NoteType.template, template.id!.toString());
    template.workoutTemplateExercises = await getExercisesForTemplate(template.id!);
    return template;
  }

  static Future<WorkoutTemplateExercise?> getTemplateExercise(int id) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutTemplateExercises)..where((te) => te.id.equals(id))).getSingleOrNull())
        ?.toObject();
  }

  static Future<List<WorkoutTemplateExercise>> getExercisesForTemplate(int workoutTemplateId) async {
    final db = DatabaseHelper.db;

    var workoutTemplateExercises = (await (db.select(db.driftWorkoutTemplateExercises)
              ..where((wte) => wte.workoutTemplateId.equals(workoutTemplateId)))
            .get())
        .map((wte) => wte.toObject())
        .toList();

    for (final wte in workoutTemplateExercises) {
      wte.workoutTemplateSets = await getSetsForTemplateExercise(wte.id!);
    }

    return workoutTemplateExercises;
  }

  static Future<List<WorkoutTemplateSet>> getSetsForTemplateExercise(int workoutTemplateExerciseId) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutTemplateSets)
              ..where((wts) => wts.workoutTemplateExerciseId.equals(workoutTemplateExerciseId)))
            .get())
        .map((wts) => wts.toObject())
        .toList();
  }

  static Future<List<String>> getExistingNames() async {
    final db = DatabaseHelper.db;
    return (await (db.selectOnly(db.driftWorkoutTemplates)..addColumns([db.driftWorkoutTemplates.name])).get())
        .map((row) => row.read(db.driftWorkoutTemplates.name))
        .whereType<String>()
        .toList();
  }

  static Future<WorkoutTemplateExercise?> getExerciseByTemplateAndExercise(
    int templateId,
    String exerciseIdentifier, {
    bool createIfNotFound = false,
  }) async {
    final db = DatabaseHelper.db;
    final workoutTemplateExericse = (await (db.select(db.driftWorkoutTemplateExercises)
              ..where((wte) => wte.workoutTemplateId.equals(templateId))
              ..where((wte) => wte.exerciseIdentifier.equals(exerciseIdentifier)))
            .getSingleOrNull())
        ?.toObject();

    if (createIfNotFound && workoutTemplateExericse == null) {
      final newWe = WorkoutTemplateExercise(
        workoutTemplateId: templateId,
        exerciseIdentifier: exerciseIdentifier,
        setOrder: '',
      );

      final weId = await insertWorkoutTemplateExercise(newWe);
      newWe.id = weId;
      return newWe;
    }

    return workoutTemplateExericse;
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
    final template = await getTemplate(workoutTemplateExercise.workoutTemplateId);
    if (template == null) return -1;

    final db = DatabaseHelper.db;
    var now = DateTime.now();
    final id = await db.into(db.driftWorkoutTemplateExercises).insert(DriftWorkoutTemplateExercisesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutTemplateId: workoutTemplateExercise.workoutTemplateId,
          exerciseIdentifier: workoutTemplateExercise.exerciseIdentifier,
          setOrder: workoutTemplateExercise.setOrder,
        ));

    template.exerciseOrder = OrderingHelper.addToOrdering(template.exerciseOrder, id);
    await update(template);
    return id;
  }

  static Future<int> insertWorkoutTemplateSet(WorkoutTemplateSet workoutTemplateSet) async {
    final templateExercise = await getTemplateExercise(workoutTemplateSet.workoutTemplateExerciseId);
    if (templateExercise == null) return -1;

    final db = DatabaseHelper.db;
    var now = DateTime.now();
    final setId = await db.into(db.driftWorkoutTemplateSets).insert(DriftWorkoutTemplateSetsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutTemplateExerciseId: workoutTemplateSet.workoutTemplateExerciseId,
          weight: Value(workoutTemplateSet.weight),
          reps: Value(workoutTemplateSet.reps),
          time: Value(workoutTemplateSet.time),
          distance: Value(workoutTemplateSet.distance),
          calsBurned: Value(workoutTemplateSet.calsBurned),
        ));

    templateExercise.setOrder = OrderingHelper.addToOrdering(templateExercise.setOrder, setId);
    await updateWorkoutTemplateExercise(templateExercise);
    return setId;
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

    final wtes = await getExercisesForTemplate(workoutTemplateId);
    for (var wte in wtes) {
      await deleteWorkoutTemplateExercise(wte.id!);
    }

    await (db.delete(db.driftWorkoutTemplates)..where((wt) => wt.id.equals(workoutTemplateId))).go();
    return true;
  }

  static Future<bool> deleteWorkoutTemplateExercise(int workoutTemplateExerciseId) async {
    final db = DatabaseHelper.db;

    final sets = await getSetsForTemplateExercise(workoutTemplateExerciseId);
    for (final set in sets) {
      await deleteWorkoutTemplateSet(set.id!);
    }

    await (db.delete(db.driftWorkoutTemplateExercises)..where((wte) => wte.id.equals(workoutTemplateExerciseId))).go();
    return true;
  }

  static Future<bool> deleteWorkoutTemplateSet(int workoutTemplateSetId) async {
    final db = DatabaseHelper.db;
    await (db.delete(db.driftWorkoutTemplateSets)..where((wts) => wts.id.equals(workoutTemplateSetId))).go();
    return true;
  }
}
