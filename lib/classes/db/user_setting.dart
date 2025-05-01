import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/enums.dart';

class UserSettings extends DatabaseObject {
  // todo: move to shared_preferences
  ThemeSetting theme;

  UserSettings({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.theme,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'theme': theme.name,
      };
}
