import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/db/custom_database.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleModel {
  static Future<List<Schedule>> getSchedules() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    if (maps.isEmpty) return [];

    List<Schedule> schedules = [];
    for (var map in maps) {
      schedules.add(Schedule(
        id: map['id'],
        updatedAt: DateTimeHelper.tryParseDateTime(map['updatedAt']),
        createdAt: DateTimeHelper.tryParseDateTime(map['createdAt']),
        name: map['name'],
        type: EnumHelper.stringToEnum(map['type'], ScheduleType.values)!,
        active: map['active'] == 1,
        startDate: DateTime.parse(map['startDate']),
      ));
    }

    return schedules;
  }

  static Future<Schedule?> getSchedule(int scheduleId, {bool shallow = false}) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('schedules', where: 'id = ?', whereArgs: [scheduleId]);
    if (maps.isEmpty) return null;

    final scheduleMap = maps.first;
    return Schedule(
      id: scheduleMap['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(scheduleMap['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(scheduleMap['createdAt']),
      name: scheduleMap['name'],
      type: EnumHelper.stringToEnum<ScheduleType>(scheduleMap['type'], ScheduleType.values)!,
      active: scheduleMap['active'] == 1,
      items: shallow ? null : await getScheduleItems(scheduleMap['id'], shallow: shallow),
      startDate: DateTime.parse(scheduleMap['startDate']),
    );
  }

  static Future<Schedule?> getActiveSchedule({bool shallow = true}) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM schedules WHERE active = 1;');
    if (maps.isEmpty) return null;

    final activeScheduleMap = maps.first;
    return Schedule(
      id: activeScheduleMap['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(activeScheduleMap['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(activeScheduleMap['createdAt']),
      name: activeScheduleMap['name'],
      type: EnumHelper.stringToEnum<ScheduleType>(activeScheduleMap['type'], ScheduleType.values)!,
      active: activeScheduleMap['active'] == 1,
      items: shallow ? null : await getScheduleItems(activeScheduleMap['id'], shallow: shallow),
      startDate: DateTime.parse(activeScheduleMap['startDate']),
    );
  }

  static Future<List<ScheduleItem>> getScheduleItems(scheduleId, {bool shallow = false}) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM schedule_items WHERE scheduleId = $scheduleId;');
    if (maps.isEmpty) return [];

    List<ScheduleItem> items = [];
    for (var map in maps) {
      items.add(ScheduleItem(
        id: map['id'],
        updatedAt: DateTimeHelper.tryParseDateTime(map['updatedAt']),
        createdAt: DateTimeHelper.tryParseDateTime(map['createdAt']),
        scheduleId: scheduleId,
        itemOrder: map['itemOrder'],
        scheduleCategories: shallow ? null : await getScheduleCategories(map['id']),
      ));
    }

    return items;
  }

  static Future<List<ScheduleCategory>> getScheduleCategories(int scheduleItemId) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM schedule_categories WHERE scheduleItemId = $scheduleItemId;');
    if (maps.isEmpty) return [];

    List<ScheduleCategory> categories = [];
    for (var map in maps) {
      categories.add(ScheduleCategory(
          id: map['id'],
          updatedAt: DateTimeHelper.tryParseDateTime(map['updatedAt']),
          createdAt: DateTimeHelper.tryParseDateTime(map['createdAt']),
          scheduleItemId: scheduleItemId,
          category: EnumHelper.stringToEnum<Category>(map['category'], Category.values)!));
    }

    return categories;
  }

  static Future<bool> setActiveSchedule(int newActiveScheduleId) async {
    try {
      final now = DateTime.now();
      final existingActiveSchedule = await getActiveSchedule(shallow: true);

      if (existingActiveSchedule != null) {
        existingActiveSchedule.active = false;
        var updateResult = await updateSchedule(existingActiveSchedule);
        if (updateResult == false) return false;
      }

      var newActiveSchedule = await getSchedule(newActiveScheduleId);
      if (newActiveSchedule == null) return false;
      newActiveSchedule.active = true;
      newActiveSchedule.startDate = now;
      return await updateSchedule(newActiveSchedule);
    } catch (e) {
      return false;
    }
  }

  static Future<int?> insertSchedule(Schedule schedule) async {
    try {
      final db = await DatabaseHelper.getDb();
      final now = DateTime.now();
      schedule.createdAt = now;
      schedule.updatedAt = now;
      return await db.insert(
        'schedules',
        schedule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateSchedule(Schedule schedule) async {
    try {
      final db = await DatabaseHelper.getDb();
      schedule.updatedAt = DateTime.now();
      await db.update(
        'schedules',
        schedule.toMap(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future insertScheduleCategories(int scheduleItemId, List<Category>? categories) async {
    if (categories == null || categories.isEmpty) return;

    try {
      final db = await DatabaseHelper.getDb();
      final now = DateTime.now();

      for (var c in categories) {
        await db.insert(
          'schedule_categories',
          ScheduleCategory(
            scheduleItemId: scheduleItemId,
            category: c,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      // ignore
    }
  }

  static Future<int?> insertScheduleItem(ScheduleItem scheduleItem) async {
    try {
      final db = await DatabaseHelper.getDb();
      final now = DateTime.now();
      scheduleItem.createdAt = now;
      scheduleItem.updatedAt = now;
      return await db.insert(
        'schedule_items',
        scheduleItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteSchedule(int scheduleId) async {
    try {
      final db = await DatabaseHelper.getDb();
      var success = await deleteScheduleItemsAndCategories(scheduleId, db: db);
      if (!success) return false;
      await db.delete('schedules', where: 'id = ?', whereArgs: [scheduleId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteScheduleItemsAndCategories(int scheduleId, {CustomDatabase? db}) async {
    try {
      db ??= await DatabaseHelper.getDb();

      var categories = [];
      var items = await getScheduleItems(scheduleId);

      for (var i in items) {
        categories.addAll(await getScheduleCategories(i.id!));
      }

      for (var i in items) {
        await db.delete('schedule_items', where: 'id = ?', whereArgs: [i.id]);
      }

      for (var c in categories) {
        await db.delete('schedule_categories', where: 'id = ?', whereArgs: [c.id]);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
