import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/enum_helper.dart';

class UserSettings extends DatabaseObject {
  UserTheme theme;
  Duration? intraSetRestTimer;

  UserSettings({
    super.id,
    super.updatedAt,
    super.createdAt,
    this.theme = UserTheme.system,
    this.intraSetRestTimer,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'theme': EnumHelper.enumToString(theme),
        'intraSetRestTimer': intraSetRestTimer?.toString() ?? '',
      };
}
