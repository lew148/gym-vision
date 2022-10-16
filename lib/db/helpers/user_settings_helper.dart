import 'package:enum_to_string/enum_to_string.dart';
import 'package:gymvision/db/classes/user_settings.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';

class UserSettingsHelper {
  static Future<UserSettings> getUserSettings() async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    return UserSettings(
      id: maps[0]['id'],
      theme: EnumToString.fromString(ThemeSetting.values, maps[0]['theme'])!,
    );
  }

  static setTheme(ThemeSetting newThemeSetting) async {
    final db = await DatabaseHelper().getDb();
    final existingSettings = await getUserSettings();
    existingSettings.theme = newThemeSetting;
    await db.update('user_settings', existingSettings.toMap());
  }
}
