import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/static_data/enums.dart';

class ScheduleCategory extends DBO {
  int scheduleItemId;
  Category category;

  ScheduleCategory({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.scheduleItemId,
    required this.category,
  });
}
