import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gymvision/db/drift_database.dart';
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

  static Future<bool> resetWhilePersistingData() async {
    var db = DatabaseHelper.db;
    final workouts = await db.select(db.driftWorkouts).get();
    final workoutCategories = await db.select(db.driftWorkoutCategories).get();
    final workoutExercises = await db.select(db.driftWorkoutExercises).get();
    final workoutSets = await db.select(db.driftWorkoutSets).get();
    final schedules = await db.select(db.driftSchedules).get();
    final scheduleItems = await db.select(db.driftScheduleItems).get();
    final scheduleCategories = await db.select(db.driftScheduleCategories).get();
    final flavourTextSchedules = await db.select(db.driftFlavourTextSchedules).get();
    final bodyweights = await db.select(db.driftBodyweights).get();
    final notes = await db.select(db.driftNotes).get();
    final settings = await db.select(db.driftSettings).getSingleOrNull();

    try {
      await resetDatabase();
      db = DatabaseHelper.db;

      for (final w in workouts) {
        await db.into(db.driftWorkouts).insert(DriftWorkoutsCompanion.insert(
              id: Value(w.id),
              createdAt: Value(w.createdAt),
              updatedAt: Value(w.updatedAt),
              date: w.date,
              exerciseOrder: w.exerciseOrder,
              endDate: Value(w.endDate),
            ));
      }

      for (final wc in workoutCategories) {
        await db.into(db.driftWorkoutCategories).insert(DriftWorkoutCategoriesCompanion.insert(
              id: Value(wc.id),
              createdAt: Value(wc.createdAt),
              updatedAt: Value(wc.updatedAt),
              workoutId: wc.workoutId,
              category: wc.category,
            ));
      }

      for (final we in workoutExercises) {
        await db.into(db.driftWorkoutExercises).insert(DriftWorkoutExercisesCompanion.insert(
              id: Value(we.id),
              createdAt: Value(we.createdAt),
              updatedAt: Value(we.updatedAt),
              workoutId: we.workoutId,
              exerciseIdentifier: we.exerciseIdentifier,
              setOrder: we.setOrder,
              done: Value(we.done),
            ));
      }

      for (final ws in workoutSets) {
        await db.into(db.driftWorkoutSets).insert(DriftWorkoutSetsCompanion.insert(
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
            ));
      }

      for (final s in schedules) {
        await db.into(db.driftSchedules).insert(DriftSchedulesCompanion.insert(
              id: Value(s.id),
              createdAt: Value(s.createdAt),
              updatedAt: Value(s.updatedAt),
              name: s.name,
              type: s.type,
              active: s.active,
              startDate: s.startDate,
            ));
      }

      for (final si in scheduleItems) {
        await db.into(db.driftScheduleItems).insert(DriftScheduleItemsCompanion.insert(
              id: Value(si.id),
              createdAt: Value(si.createdAt),
              updatedAt: Value(si.updatedAt),
              scheduleId: si.scheduleId,
              itemOrder: si.itemOrder,
            ));
      }

      for (final sc in scheduleCategories) {
        await db.into(db.driftScheduleCategories).insert(DriftScheduleCategoriesCompanion.insert(
              id: Value(sc.id),
              createdAt: Value(sc.createdAt),
              updatedAt: Value(sc.updatedAt),
              scheduleItemId: sc.scheduleItemId,
              category: sc.category,
            ));
      }

      for (final fts in flavourTextSchedules) {
        await db.into(db.driftFlavourTextSchedules).insert(DriftFlavourTextSchedulesCompanion.insert(
              id: Value(fts.id),
              createdAt: Value(fts.createdAt),
              updatedAt: Value(fts.updatedAt),
              flavourTextId: fts.flavourTextId,
              date: fts.date,
              dismissed: Value(fts.dismissed),
            ));
      }

      for (final bw in bodyweights) {
        await db.into(db.driftBodyweights).insert(DriftBodyweightsCompanion.insert(
              id: Value(bw.id),
              createdAt: Value(bw.createdAt),
              updatedAt: Value(bw.updatedAt),
              date: bw.date,
              weight: bw.weight,
              units: bw.units,
            ));
      }

      for (final n in notes) {
        await db.into(db.driftNotes).insert(DriftNotesCompanion.insert(
              id: Value(n.id),
              createdAt: Value(n.createdAt),
              updatedAt: Value(n.updatedAt),
              objectId: n.objectId,
              type: n.type,
              note: n.note,
            ));
      }

      if (settings != null) {
        await db.update(db.driftSettings).write(DriftSettingsCompanion(
              theme: Value(settings.theme),
              intraSetRestTimer: Value(settings.intraSetRestTimer),
            ));
      }

      return true;
    } catch (ex) {
      return false;
    }
  }
}
