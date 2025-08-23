import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';

class NoteModel {
  static const _tableName = 'notes';

  static Future<Note?> getNoteForObject(NoteType type, String objectId) async {
    final db = await DatabaseHelper.getDb();
    var maps = await db.query(_tableName, where: 'type = ? AND objectId = ?', whereArgs: [type.toString(), objectId]);
    if (maps.isEmpty) return null;

    final Map<String, dynamic> map = maps.first;
    return Note(
      id: map['id'],
      updatedAt: DateTimeHelper.tryParseDateTime(map['updatedAt']),
      createdAt: DateTimeHelper.tryParseDateTime(map['createdAt']),
      objectId: map['objectId'],
      type: EnumHelper.stringToEnum(map['type'], NoteType.values) ?? NoteType.other,
      note: map['note'],
    );
  }

  static Future<bool> addNote(Note note) async {
    try {
      final db = await DatabaseHelper.getDb();
      final now = DateTime.now();
      note.createdAt = now;
      note.updatedAt = now;
      await db.insert(_tableName, note.toMap());
      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> updateNote(Note note) async {
    try {
      final db = await DatabaseHelper.getDb();
      note.updatedAt = DateTime.now();
      await db.update(
        _tableName,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> deleteNote(int id) async {
    try {
      final db = await DatabaseHelper.getDb();
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      return false;
    }
  }
}
