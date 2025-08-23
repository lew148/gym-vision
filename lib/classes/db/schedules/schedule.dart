import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/static_data/enums.dart';

class Schedule extends DatabaseObject {
  String name;
  ScheduleType type;
  bool active;
  DateTime startDate;

  List<ScheduleItem>? items;

  Schedule({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.name,
    required this.type,
    required this.active,
    required this.startDate,
    this.items,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'name': name,
        'type': EnumHelper.enumToString(type),
        'active': active ? 1 : 0,
        'startDate': startDate.toString(),
      };

  int indexOfTodaysScheduleItem() {
    final daysSinceStart = DateTimeHelper.daysBetween(startDate, DateTime.now());
    if (daysSinceStart == 0 || items == null) return 0;

    int p = 0, index = 0;

    while (p < daysSinceStart) {
      if (index == items!.length - 1) {
        index = 0;
      } else {
        index++;
      }

      p++;
    }

    return index;
  }

  List<Category> getCategoriesForDay(DateTime dt) {
    if (items == null || items!.isEmpty) return [];

    ScheduleItem? todaysItem;

    switch (type) {
      case ScheduleType.split:
        todaysItem = items![indexOfTodaysScheduleItem()];
        break;
      case ScheduleType.weekly:
        final weekday = DateTime.now().weekday;
        todaysItem = items!.firstWhere((i) => i.itemOrder == weekday);
        break;
      case ScheduleType.biweekly:
        throw UnimplementedError();
    }

    return todaysItem.scheduleCategories?.map((sc) => sc.category).toList() ?? [];
  }
}
