import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';

class NoteModel {
  static Future<Note?> getNoteForObject(NoteType type, String objectId) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftNotes)
              ..where((n) => n.type.equalsValue(type))
              ..where((n) => n.objectId.equals(objectId)))
            .getSingleOrNull())
        ?.toObject();
  }

  static Future<int> insert(Note note) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftNotes).insert(DriftNotesCompanion(
          createdAt: Value(now),
          updatedAt: Value(now),
          objectId: Value(note.objectId),
          type: Value(note.type),
          note: Value(note.note),
        ));
  }

  static Future<bool> update(Note note) async {
    if (note.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftNotes)..where((s) => s.id.equals(note.id!))).write(DriftNotesCompanion(
      updatedAt: Value(DateTime.now()),
      objectId: Value(note.objectId),
      type: Value(note.type),
      note: Value(note.note),
    ));

    return true;
  }

  static Future<int> delete(int id) async {
    final db = DatabaseHelper.db;
    return await (db.delete(db.driftNotes)..where((n) => n.id.equals(id))).go();
  }
}
