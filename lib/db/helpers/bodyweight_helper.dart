import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class BodyweightHelper {
  static Future<Bodyweight?> getBodyweightForDay(DateTime date) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'bodyweights',
      where: 'date LIKE ?',
      whereArgs: ['%${date.year}-${date.month}-${date.day}%'],
    );

    if (maps.isEmpty) return null;

    return Bodyweight(
      id: maps[0]['id'],
      date: DateTime.parse(maps[0]['date']),
      weight: maps[0]['weight'],
      units: maps[0]['units'],
    );
  }

  static Future<List<Bodyweight>> getBodyweights() async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query('bodyweights');

    List<Bodyweight> bws = [];
    for (var map in maps) {
      bws.add(Bodyweight(
        id: map['id'],
        date: DateTime.parse(map['date']),
        weight: map['weight'],
        units: map['units'],
      ));
    }

    return bws;
  }

  static insertBodyweight(Bodyweight bodyweight) async {
    final db = await DatabaseHelper.getDb();
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
