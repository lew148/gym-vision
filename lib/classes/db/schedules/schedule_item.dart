import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';

class ScheduleItem extends DBO {
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

  bool isRest() => scheduleCategories == null || scheduleCategories!.isEmpty;
}
