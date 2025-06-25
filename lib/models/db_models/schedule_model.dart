import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/static_data/enums.dart';

var test = Schedule(
  active: true,
  name: 'Big Boy Split',
  type: ScheduleType.split,
  items: [
    ScheduleItem(
      scheduleId: 1,
      order: 1,
      scheduleCategories: [ScheduleCategory(scheduleItemId: 1, category: Category.chest)],
    ),
    ScheduleItem(
      scheduleId: 1,
      order: 2,
      scheduleCategories: [ScheduleCategory(scheduleItemId: 1, category: Category.back)],
    ),
    ScheduleItem(
      scheduleId: 1,
      order: 3,
      scheduleCategories: [ScheduleCategory(scheduleItemId: 1, category: Category.arms)],
    ),
    ScheduleItem(
      scheduleId: 1,
      order: 4,
      scheduleCategories: [
        ScheduleCategory(scheduleItemId: 1, category: Category.shoulders),
        ScheduleCategory(scheduleItemId: 1, category: Category.core),
      ],
    ),
    ScheduleItem(
      scheduleId: 1,
      order: 5,
      scheduleCategories: [
        ScheduleCategory(scheduleItemId: 1, category: Category.legs),
      ],
    ),
  ],
);

class ScheduleModel {
  static Future<List<Schedule>?> getSchedules() async {
    // final db = await DatabaseHelper.getDb();
    return [test];
  }

  static Future<Schedule?> getActiveSchedule() async {
    // final db = await DatabaseHelper.getDb();
    return test;
  }

  static Future<bool> setActiveSchedule() async {
    return true;
  }
}
