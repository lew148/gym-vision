import 'package:gymvision/enums.dart';

class UserSettings {
  int? id;
  ThemeSetting theme;
  DateTime firstUse;

  UserSettings({
    this.id,
    required this.theme,
    required this.firstUse,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'theme': theme.name,
        'firstUse': firstUse.toString()
      };
}
