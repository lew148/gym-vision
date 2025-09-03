import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';

class BodyweightModel {
  static Future<Bodyweight?> getBodyweightForDay(DateTime date) async {
    final db = DatabaseHelper.db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (await (db.select(db.driftBodyweights)
              ..where((w) => w.date.isBiggerOrEqualValue(startOfDay))
              ..where((w) => w.date.isSmallerThanValue(endOfDay)))
            .getSingleOrNull())
        ?.toObject();
  }

  static Future<List<Bodyweight>> getBodyweights() async {
    final db = DatabaseHelper.db;
    return (await db.select(db.driftBodyweights).get()).map((b) => b.toObject()).toList();
  }

  static Future<int> insert(Bodyweight bw) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftBodyweights).insert(DriftBodyweightsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          date: bw.date,
          weight: bw.weight,
          units: bw.units,
        ));
  }

  static Future<int> delete(int id) async {
    final db = DatabaseHelper.db;
    return await (db.delete(db.driftBodyweights)..where((bw) => bw.id.equals(id))).go();
  }
}
