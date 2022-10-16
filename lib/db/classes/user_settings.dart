import 'package:gymvision/enums.dart';

class UserSettings {
  int? id;
  ThemeSetting theme;

  UserSettings({this.id, required this.theme});

  Map<String, dynamic> toMap() =>
      {'id': id, 'theme': theme.name};
}
