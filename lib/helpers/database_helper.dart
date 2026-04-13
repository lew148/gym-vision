import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DatabaseHelper {
  static AppDatabase? _database;

  static AppDatabase get db {
    if (_database == null) {
      initialiseDatabase();
    }

    return _database!;
  }

  static const String databaseName = 'gymvision.db';

  static Future<void> initialiseDatabase() async {
    try {
      _database = AppDatabase(openConnection());
    } catch (ex, st) {
      await Sentry.captureException(ex, stackTrace: st);
      rethrow;
    }
  }

  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, DatabaseHelper.databaseName));
      return NativeDatabase.createInBackground(file);
    });
  }

  static Future<void> resetDatabase() async {
    await _database?.close();
    await deleteDatabaseFile();
    await initialiseDatabase();
  }

  static Future<void> deleteDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, databaseName));
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<List<T>> trySelectList<T>(Future<List<T>> Function() select) async {
    try {
      return await select();
    } catch (e) {
      return [];
    }
  }

  static Future<T?> trySelectSingle<T>(Future<T?> Function() select) async {
    try {
      return await select();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> resetWhilePersistingData() async {
    var db = DatabaseHelper.db;

    final workouts = await trySelectList(() async => await db.select(db.driftWorkouts).get());
    final workoutCategories = await trySelectList(() async => await db.select(db.driftWorkoutCategories).get());
    final workoutExercises = await trySelectList(() async => await db.select(db.driftWorkoutExercises).get());
    final workoutSets = await trySelectList(() async => await db.select(db.driftWorkoutSets).get());
    final schedules = await trySelectList(() async => await db.select(db.driftSchedules).get());
    final scheduleItems = await trySelectList(() async => await db.select(db.driftScheduleItems).get());
    final scheduleCategories = await trySelectList(() async => await db.select(db.driftScheduleCategories).get());
    final flavourTextSchedules = await trySelectList(() async => await db.select(db.driftFlavourTextSchedules).get());
    final bodyweights = await trySelectList(() async => await db.select(db.driftBodyweights).get());
    final notes = await trySelectList(() async => await db.select(db.driftNotes).get());
    final settings = await trySelectSingle(() async => await db.select(db.driftSettings).getSingleOrNull());
    final templates = await trySelectList(() async => await db.select(db.driftWorkoutTemplates).get());
    final templateExercises = await trySelectList(() async => await db.select(db.driftWorkoutTemplateExercises).get());
    final templateSets = await trySelectList(() async => await db.select(db.driftWorkoutTemplateSets).get());
    final userImages = await trySelectList(() async => await db.select(db.driftUserImages).get());

    try {
      await resetDatabase();
    } catch (ex) {
      return false;
    }

    db = DatabaseHelper.db;

    for (final w in workouts) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkouts).insert(DriftWorkoutsCompanion.insert(
              id: Value(w.id),
              createdAt: Value(w.createdAt),
              updatedAt: Value(w.updatedAt),
              date: w.date,
              exerciseOrder: w.exerciseOrder,
              endDate: Value(w.endDate),
            )),
      );
    }

    for (final wc in workoutCategories) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkoutCategories).insert(DriftWorkoutCategoriesCompanion.insert(
              id: Value(wc.id),
              createdAt: Value(wc.createdAt),
              updatedAt: Value(wc.updatedAt),
              workoutId: wc.workoutId,
              category: wc.category,
            )),
      );
    }

    for (final we in workoutExercises) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkoutExercises).insert(DriftWorkoutExercisesCompanion.insert(
              id: Value(we.id),
              createdAt: Value(we.createdAt),
              updatedAt: Value(we.updatedAt),
              workoutId: we.workoutId,
              exerciseIdentifier: we.exerciseIdentifier,
              setOrder: we.setOrder,
              done: Value(we.done),
            )),
      );
    }

    for (final ws in workoutSets) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkoutSets).insert(DriftWorkoutSetsCompanion.insert(
              id: Value(ws.id),
              createdAt: Value(ws.createdAt),
              updatedAt: Value(ws.updatedAt),
              workoutExerciseId: ws.workoutExerciseId,
              weight: Value(ws.weight),
              reps: Value(ws.reps),
              time: Value(ws.time),
              distance: Value(ws.distance),
              calsBurned: Value(ws.calsBurned),
              done: Value(ws.done),
              addedWeight: Value(ws.addedWeight),
              assistedWeight: Value(ws.assistedWeight),
            )),
      );
    }

    for (final s in schedules) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftSchedules).insert(DriftSchedulesCompanion.insert(
              id: Value(s.id),
              createdAt: Value(s.createdAt),
              updatedAt: Value(s.updatedAt),
              name: s.name,
              type: s.type,
              active: s.active,
              startDate: s.startDate,
            )),
      );
    }

    for (final si in scheduleItems) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftScheduleItems).insert(DriftScheduleItemsCompanion.insert(
              id: Value(si.id),
              createdAt: Value(si.createdAt),
              updatedAt: Value(si.updatedAt),
              scheduleId: si.scheduleId,
              itemOrder: si.itemOrder,
            )),
      );
    }

    for (final sc in scheduleCategories) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftScheduleCategories).insert(DriftScheduleCategoriesCompanion.insert(
              id: Value(sc.id),
              createdAt: Value(sc.createdAt),
              updatedAt: Value(sc.updatedAt),
              scheduleItemId: sc.scheduleItemId,
              category: sc.category,
            )),
      );
    }

    for (final fts in flavourTextSchedules) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftFlavourTextSchedules).insert(DriftFlavourTextSchedulesCompanion.insert(
              id: Value(fts.id),
              createdAt: Value(fts.createdAt),
              updatedAt: Value(fts.updatedAt),
              flavourTextId: fts.flavourTextId,
              date: fts.date,
              dismissed: Value(fts.dismissed),
            )),
      );
    }

    for (final bw in bodyweights) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftBodyweights).insert(DriftBodyweightsCompanion.insert(
              id: Value(bw.id),
              createdAt: Value(bw.createdAt),
              updatedAt: Value(bw.updatedAt),
              date: bw.date,
              weight: bw.weight,
              units: bw.units,
            )),
      );
    }

    for (final n in notes) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftNotes).insert(DriftNotesCompanion.insert(
              id: Value(n.id),
              createdAt: Value(n.createdAt),
              updatedAt: Value(n.updatedAt),
              objectId: n.objectId,
              type: n.type,
              note: n.note,
            )),
      );
    }

    if (settings != null) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.update(db.driftSettings).write(DriftSettingsCompanion(
              theme: Value(settings.theme),
              intraSetRestTimer: Value(settings.intraSetRestTimer),
            )),
      );
    }

    for (final t in templates) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkoutTemplates).insert(DriftWorkoutTemplatesCompanion.insert(
              id: Value(t.id),
              createdAt: Value(t.createdAt),
              updatedAt: Value(t.updatedAt),
              name: t.name,
              categories: t.categories,
              exerciseOrder: t.exerciseOrder,
            )),
      );
    }

    for (final te in templateExercises) {
      await AppHelper.runAsyncVoidWithRetries(
        () async =>
            await db.into(db.driftWorkoutTemplateExercises).insert(DriftWorkoutTemplateExercisesCompanion.insert(
                  id: Value(te.id),
                  createdAt: Value(te.createdAt),
                  updatedAt: Value(te.updatedAt),
                  workoutTemplateId: te.workoutTemplateId,
                  exerciseIdentifier: te.exerciseIdentifier,
                  setOrder: te.setOrder,
                )),
      );
    }

    for (final ts in templateSets) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftWorkoutTemplateSets).insert(DriftWorkoutTemplateSetsCompanion.insert(
              id: Value(ts.id),
              createdAt: Value(ts.createdAt),
              updatedAt: Value(ts.updatedAt),
              workoutTemplateExerciseId: ts.workoutTemplateExerciseId,
              weight: Value(ts.weight),
              reps: Value(ts.reps),
              time: Value(ts.time),
              distance: Value(ts.distance),
              calsBurned: Value(ts.calsBurned),
              done: Value(ts.done),
            )),
      );
    }

    for (final ui in userImages) {
      await AppHelper.runAsyncVoidWithRetries(
        () async => await db.into(db.driftUserImages).insert(DriftUserImagesCompanion.insert(
              id: Value(ui.id),
              createdAt: Value(ui.createdAt),
              updatedAt: Value(ui.updatedAt),
              name: ui.name,
              storageType: ui.storageType,
              imageType: ui.imageType,
              source: Value(ui.source),
              relativePath: Value(ui.relativePath),
              takenAt: Value(ui.takenAt),
            )),
      );
    }

    return true;
  }
}
