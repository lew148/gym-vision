import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';

class UserSettingsModel {
  static Future<UserSettings> getUserSettings() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    return UserSettings(
      id: maps[0]['id'],
      updatedAt: tryParseDateTime(maps[0]['updatedAt']),
      createdAt: tryParseDateTime(maps[0]['createdAt']),
      theme: stringToEnum(maps[0]['theme'], ThemeSetting.values) ?? ThemeSetting.system,
    );
  }

  static setTheme(ThemeSetting newThemeSetting) async {
    final db = await DatabaseHelper.getDb();
    final existingSettings = await getUserSettings();
    existingSettings.theme = newThemeSetting;
    await db.update('user_settings', existingSettings.toMap());
  }
}
