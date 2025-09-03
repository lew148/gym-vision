import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';

class UserSettingsModel {
  static Future<UserSettings> getUserSettings() async {
    final db = DatabaseHelper.db;
    return (await db.select(db.driftSettings).getSingle()).toObject();
  }

  static Future<bool> update(UserSettings settings) async {
    if (settings.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftSettings)..where((s) => s.id.equals(settings.id!))).write(DriftSettingsCompanion(
      updatedAt: Value(DateTime.now()),
      theme: Value(settings.theme),
      intraSetRestTimer: Value(settings.intraSetRestTimer),
    ));

    return true;
  }
}
