import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:sqflite/sqflite.dart';

class BodyweightModel {
  static Future<Bodyweight?> getBodyweightForDay(DateTime date) async {
    final db = await DatabaseHelper.getDb();
    final dateStr = "${date.year}-${getMonthOrDayString(date.month)}-${getMonthOrDayString(date.day)}";
    final List<Map<String, dynamic>> maps = await db.query(
      'bodyweights',
      where: 'bodyweights.date LIKE ?',
      whereArgs: ['%$dateStr%'],
    );

    if (maps.isEmpty) return null;
    return Bodyweight(
      id: maps.first['id'],
      updatedAt: tryParseDateTime(maps.first['updatedAt']),
      createdAt: tryParseDateTime(maps.first['createdAt']),
      date: parseDateTime(maps.first['date']),
      weight: maps.first['weight'],
      units: maps.first['units'],
    );
  }

  static Future<List<Bodyweight>> getBodyweights() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('bodyweights');

    List<Bodyweight> bws = [];
    for (var map in maps) {
      bws.add(Bodyweight(
      id: map['id'],
      updatedAt: tryParseDateTime(map['updatedAt']),
      createdAt: tryParseDateTime(map['createdAt']),
      date: parseDateTime(map['date']),
      weight: map['weight'],
      units: map['units'],
    ));
    }

    return bws;
  }

  static insertBodyweight(Bodyweight bodyweight) async {
    final db = await DatabaseHelper.getDb();
    final now = DateTime.now();
    bodyweight.createdAt = now;
    bodyweight.updatedAt = now;
    await db.insert(
      'bodyweights',
      bodyweight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static deleteBodyweight(int bodyweightId) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'bodyweights',
      where: 'id = ?',
      whereArgs: [bodyweightId],
    );
  }
}
