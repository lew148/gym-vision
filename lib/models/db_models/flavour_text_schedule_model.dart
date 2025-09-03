import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/flavour_text_model.dart';

class FlavourTextScheduleModel {
  static Future<FlavourTextSchedule> getTodaysFlavourTextSchedule() async {
    final lastFive = await getRecentFlavourTextSchedules();
    if (lastFive.isNotEmpty && DateTimeHelper.isToday(lastFive.first.date)) {
      return lastFive.first;
    }

    return insert(lastFive.map((fts) => fts.flavourTextId).toList());
  }

  static Future<List<FlavourTextSchedule>> getRecentFlavourTextSchedules({int limit = 5}) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftFlavourTextSchedules)
              ..orderBy([(fts) => OrderingTerm.desc(db.driftFlavourTextSchedules.date)])
              ..limit(limit))
            .get())
        .map((fts) => fts.toObject())
        .toList();
  }

  static Future<FlavourTextSchedule> insert(List<int> excludedFlavourTextInts) async {
    final newFlavourText = FlavourTextModel.getRandomFlavourText(excludedFlavourTextInts);
    final now = DateTime.now();
    var newObj = FlavourTextSchedule(
      flavourTextId: newFlavourText.id,
      updatedAt: now,
      createdAt: now,
      date: now,
      dismissed: false,
    );

    final db = DatabaseHelper.db;
    newObj.id = await db.into(db.driftFlavourTextSchedules).insert(DriftFlavourTextSchedulesCompanion.insert(
          createdAt: Value(newObj.createdAt),
          updatedAt: Value(newObj.updatedAt),
          flavourTextId: newObj.flavourTextId,
          date: newObj.date,
          dismissed: Value(newObj.dismissed),
        ));
    return newObj;
  }

  static Future<bool> setFlavourTextScheduleDismissed(FlavourTextSchedule fts, {bool dismissed = true}) async {
    if (fts.id == null) return false;
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    await (db.update(db.driftFlavourTextSchedules)..where((s) => s.id.equals(fts.id!)))
        .write(DriftFlavourTextSchedulesCompanion(
      date: Value(now),
      updatedAt: Value(now),
      dismissed: Value(dismissed),
    ));
    return true;
  }

  static Future<bool> setRecentFlavourTextScheduleNotDismissed() async =>
      await setFlavourTextScheduleDismissed((await getRecentFlavourTextSchedules()).first, dismissed: false);
}
