import 'package:gymvision/db/classes/flavour_text.dart';
import 'package:gymvision/db/classes/flavour_text_schedule.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:sqflite/sqflite.dart';

class FlavourTextHelper {
  static Future<FlavourTextSchedule> getTodaysFlavourTextSchedule() async {
    final db = await DatabaseHelper.getDb();

    final recentFlavourTextSchedules = await getRecentFlavourTextSchedules(db);
    if (recentFlavourTextSchedules.isNotEmpty && isToday(recentFlavourTextSchedules[0].date)) {
      return recentFlavourTextSchedules[0];
    }

    return addNewFlavourTextSchedule(
      db,
      recentFlavourTextSchedules.map((fts) => fts.flavourTextId).toList(),
    );
  }

  static Future<List<FlavourTextSchedule>> getRecentFlavourTextSchedules(
    Database db,
  ) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT
          flavour_text_schedules.id,
          flavour_text_schedules.flavourTextId,
          flavour_text_schedules.date,
          flavour_text_schedules.dismissed,
          flavour_texts.message
        FROM flavour_text_schedules
        LEFT JOIN flavour_texts ON flavour_text_schedules.flavourTextId = flavour_texts.id
        ORDER BY date DESC LIMIT 5;
      ''',
    );

    return List.generate(
      maps.length,
      (i) => FlavourTextSchedule(
        id: maps[i]['id'],
        flavourTextId: maps[i]['flavourTextId'],
        date: DateTime.parse(maps[i]['date']),
        dismissed: maps[i]['dismissed'] == 1,
        flavourText: FlavourText(
          id: maps[i]['flavourTextId'],
          message: maps[i]['message'],
        ),
      ),
    );
  }

  static Future<FlavourTextSchedule> addNewFlavourTextSchedule(
    Database db,
    List<int> excludedFlavourTextInts,
  ) async {
    final newFlavourText = await getRandomFlavourText(excludedFlavourTextInts);
    var newFlavourTextSchedule = FlavourTextSchedule(
      flavourTextId: newFlavourText.id!,
      date: DateTime.now(),
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

  static Future<FlavourText> getRandomFlavourText(
    List<int> excludedFlavourTextInts,
  ) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT * FROM flavour_texts
        WHERE id NOT IN (${excludedFlavourTextInts.join(',')})
        ORDER BY RANDOM() LIMIT 1;
      ''',
    );

    // todo: REMOVE
    if (maps.isEmpty) return FlavourText(message: 'Dummy FT');

    return FlavourText(
      id: maps[0]['id'],
      message: maps[0]['message'],
    );
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
    final FlavourTextSchedule mostRecentFTS = await getMostRecentFlavourTextSchedule(db);
    mostRecentFTS.dismissed = false;
    await db.update(
      'flavour_text_schedules',
      mostRecentFTS.toMap(),
      where: 'id = ?',
      whereArgs: [mostRecentFTS.id],
    );
  }

  static Future<FlavourTextSchedule> getMostRecentFlavourTextSchedule(
    Database db,
  ) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM flavour_text_schedules ORDER BY date DESC LIMIT 5;',
    );

    return FlavourTextSchedule(
      id: maps[0]['id'],
      flavourTextId: maps[0]['flavourTextId'],
      date: DateTime.parse(maps[0]['date']),
      dismissed: maps[0]['dismissed'] == 1,
    );
  }
}
