import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';

class ScheduleItem extends DatabaseObject {
  int scheduleId;
  int itemOrder;

  // non-db props
  List<ScheduleCategory>? scheduleCategories;

  ScheduleItem({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.scheduleId,
    required this.itemOrder,
    this.scheduleCategories,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'scheduleId': scheduleId,
        'itemOrder': itemOrder,
      };

  bool isRest() => scheduleCategories == null || scheduleCategories!.isEmpty;
}
