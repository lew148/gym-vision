import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';

class ScheduleCategory extends DatabaseObject {
  int scheduleItemId;
  Category category;

  ScheduleCategory({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.scheduleItemId,
    required this.category,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'scheduleItemId': scheduleItemId,
        'category': enumToString(category),
      };
}
