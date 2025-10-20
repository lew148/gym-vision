import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/static_data/enums.dart';

class ScheduleModel {
  static Future<List<Schedule>> getAllSchedules() async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftSchedules)).get()).map((s) => s.toObject()).toList();
  }

  static Future<Schedule?> getSchedule(int id, {bool withItems = false}) async {
    final db = DatabaseHelper.db;
    final schedule =
        (await (db.select(db.driftSchedules)..where((s) => s.id.equals(id))).getSingleOrNull())?.toObject();
    if (schedule == null) return null;

    if (withItems) {
      schedule.items = await getItemsBySchedule(schedule.id!, withCategories: withItems);
    }

    return schedule;
  }

  static Future<Schedule?> getActiveSchedule({bool withItems = true}) async {
    final db = DatabaseHelper.db;
    final schedule =
        (await (db.select(db.driftSchedules)..where((s) => s.active.equals(true))).getSingleOrNull())?.toObject();
    if (schedule == null) return null;

    if (withItems) {
      schedule.items = await getItemsBySchedule(schedule.id!, withCategories: withItems);
    }

    return schedule;
  }

  static Future<List<ScheduleItem>> getItemsBySchedule(int scheduleId, {bool withCategories = false}) async {
    final db = DatabaseHelper.db;
    final items = (await (db.select(db.driftScheduleItems)..where((i) => i.scheduleId.equals(scheduleId))).get())
        .map((i) => i.toObject())
        .toList();

    if (withCategories) {
      for (final item in items) {
        item.scheduleCategories = await getScheduleCategoriesByItem(item.id!);
      }
    }

    return items;
  }

  static Future<List<ScheduleCategory>> getScheduleCategoriesByItem(int scheduleItemId) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftScheduleCategories)..where((c) => c.scheduleItemId.equals(scheduleItemId))).get())
        .map((i) => i.toObject())
        .toList();
  }

  static Future<bool> setActiveSchedule(int newActiveScheduleId) async {
    try {
      final now = DateTime.now();
      final existingActiveSchedule = await getActiveSchedule(withItems: true);

      if (existingActiveSchedule != null) {
        existingActiveSchedule.active = false;
        var updateResult = await update(existingActiveSchedule);
        if (updateResult == false) return false;
      }

      var newActiveSchedule = await getSchedule(newActiveScheduleId);
      if (newActiveSchedule == null) return false;
      newActiveSchedule.active = true;
      newActiveSchedule.startDate = now;
      return await update(newActiveSchedule);
    } catch (e) {
      return false;
    }
  }

  static Future<int?> insert(Schedule schedule) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftSchedules).insert(DriftSchedulesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          name: schedule.name,
          type: schedule.type,
          active: schedule.active,
          startDate: schedule.startDate,
        ));
  }

  static Future<bool> update(Schedule schedule) async {
    final db = DatabaseHelper.db;
    if (schedule.id == null) return false;
    await (db.update(db.driftSchedules)..where((s) => s.id.equals(schedule.id!))).write(DriftSchedulesCompanion(
      updatedAt: Value(DateTime.now()),
      name: Value(schedule.name),
      type: Value(schedule.type),
      active: Value(schedule.active),
      startDate: Value(schedule.startDate),
    ));

    return true;
  }

  static Future<int?> insertScheduleItem(ScheduleItem scheduleItem) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftScheduleItems).insert(DriftScheduleItemsCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          scheduleId: scheduleItem.scheduleId,
          itemOrder: scheduleItem.itemOrder,
        ));
  }

  static Future<int?> insertScheduleCategory(ScheduleCategory scheduleCategory) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftScheduleCategories).insert(DriftScheduleCategoriesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          scheduleItemId: scheduleCategory.scheduleItemId,
          category: scheduleCategory.category,
        ));
  }

  static Future insertScheduleCategories(int scheduleItemId, List<Category>? categories) async {
    if (categories == null || categories.isEmpty) return;
    for (var c in categories) {
      await insertScheduleCategory(ScheduleCategory(scheduleItemId: scheduleItemId, category: c));
    }
  }

  static Future<bool> delete(int id) async {
    var success = await deleteScheduleItemsAndCategories(id);
    if (!success) return false;
    final db = DatabaseHelper.db;
    await (db.delete(db.driftSchedules)..where((s) => s.id.equals(id))).go();
    return true;
  }

  static Future<bool> deleteScheduleItemsAndCategories(int scheduleId) async {
    try {
      final List<int> itemIds = [];
      final List<int> categoryIds = [];

      var items = await getItemsBySchedule(scheduleId, withCategories: true);
      for (final item in items) {
        itemIds.add(item.id!);
        if (item.scheduleCategories == null || item.scheduleCategories!.isEmpty) continue;
        categoryIds.addAll(item.scheduleCategories!.map((c) => c.id!));
      }

      final db = DatabaseHelper.db;
      await (db.delete(db.driftScheduleCategories)..where((c) => c.id.isIn(categoryIds))).go();
      await (db.delete(db.driftScheduleItems)..where((i) => i.id.isIn(itemIds))).go();
      return true;
    } catch (e) {
      return false;
    }
  }
}
