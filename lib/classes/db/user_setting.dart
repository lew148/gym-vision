import 'package:gymvision/classes/db/_database_object.dart';

class UserSettings extends DatabaseObject {
  UserSettings({
    super.id,
    super.updatedAt,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
      };
}
