import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/helpers/datetime_helper.dart';

class UserSettingsModel {
  static Future<UserSettings> getUserSettings() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    return UserSettings(
      id: maps[0]['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(maps[0]['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(maps[0]['createdAt']),
    );
  }
}
