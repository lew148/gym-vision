import 'package:sqflite/sqflite.dart';

class Migrations {
  static void addNotesColumnToExercises(Batch batch) => batch.execute('ALTER TABLE exercises ADD notes TEXT;');
}
