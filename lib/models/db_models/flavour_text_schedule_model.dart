import 'package:collection/collection.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/flavour_text_model.dart';
import 'package:gymvision/static_data/data/flavour_texts.dart';
import 'package:sqflite/sqflite.dart';

class FlavourTextScheduleModel {
  static Future<FlavourTextSchedule> getTodaysFlavourTextSchedule() async {
    final db = await DatabaseHelper.getDb();

    final recentFlavourTextSchedules = await getRecentFlavourTextSchedules(db);
    if (recentFlavourTextSchedules.isNotEmpty && isToday(recentFlavourTextSchedules[0].date)) {
      return recentFlavourTextSchedules[0];
    }

    return addNewFlavourTextSchedule(db, recentFlavourTextSchedules.map((fts) => fts.flavourTextId).toList());
  }

  static Future<List<FlavourTextSchedule>> getRecentFlavourTextSchedules(Database db) async {
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM flavour_text_schedules ORDER BY date DESC LIMIT 5;');

    return List.generate(
      maps.length,
      (i) => FlavourTextSchedule(
        id: maps[i]['id'],
        updatedAt: tryParseDateTime(maps[i]['updatedAt'] ?? ''),
        createdAt: tryParseDateTime(maps[i]['createdAt'] ?? ''),
        flavourTextId: maps[i]['flavourTextId'],
        date: parseDateTime(maps[i]['date'] ?? ''),
        dismissed: maps[i]['dismissed'] == 1,
        flavourText: flavourTexts.firstWhereOrNull((ft) => ft.id == maps[i]['flavourTextId']),
      ),
    );
  }

  static Future<FlavourTextSchedule> addNewFlavourTextSchedule(
    Database db,
    List<int> excludedFlavourTextInts,
  ) async {
    final newFlavourText = FlavourTextModel.getRandomFlavourText(excludedFlavourTextInts);
    final now = DateTime.now();
    var newFlavourTextSchedule = FlavourTextSchedule(
      flavourTextId: newFlavourText.id,
      updatedAt: now,
      createdAt: now,
      date: now,
      dismissed: false,
    );

    int ftsId = await db.insert(
      'flavour_text_schedules',
      newFlavourTextSchedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    newFlavourTextSchedule.id = ftsId;
    newFlavourTextSchedule.flavourText = newFlavourText;
    return newFlavourTextSchedule;
  }

  static setFlavourTextScheduleDismissed(FlavourTextSchedule fts) async {
    final db = await DatabaseHelper.getDb();
    fts.dismissed = true;
    await db.update(
      'flavour_text_schedules',
      fts.toMap(),
      where: 'id = ?',
      whereArgs: [fts.id],
    );
  }

  static setRecentFlavourTextScheduleNotDismissed() async {
    final db = await DatabaseHelper.getDb();
    final FlavourTextSchedule mostRecentFTS = (await getRecentFlavourTextSchedules(db)).first;
    mostRecentFTS.dismissed = false;
    await db.update(
      'flavour_text_schedules',
      mostRecentFTS.toMap(),
      where: 'id = ?',
      whereArgs: [mostRecentFTS.id],
    );
  }
}
