import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class BodyweightHelper {
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
