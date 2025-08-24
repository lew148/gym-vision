import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';

class UserSettingsModel {
  static Future<UserSettings> getUserSettings() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    return UserSettings(
      id: maps.first['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(maps.first['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(maps.first['createdAt']),
      theme: EnumHelper.stringToEnum(maps.first['theme'], UserTheme.values) ?? UserTheme.system,
      intraSetRestTimer: DateTimeHelper.tryParseDuration(maps.first['intraSetRestTimer']),
    );
  }

  static Future<bool> updateUserSettings(UserSettings settings) async {
    final db = await DatabaseHelper.getDb();
    settings.updatedAt = DateTime.now();
    await db.update('user_settings', settings.toMap());
    return true;
  }
}
