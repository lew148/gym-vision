import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/enums.dart';

class UserSettings extends DBO {
  UserTheme theme;
  Duration? intraSetRestTimer;

  UserSettings({
    super.id,
    super.updatedAt,
    super.createdAt,
    this.theme = UserTheme.system,
    this.intraSetRestTimer,
  });
}
