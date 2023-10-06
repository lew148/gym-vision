import 'package:gymvision/helpers/data_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'migrations.dart';

class DatabaseHelper {
  static Future<Database>? database;

  static deleteDb() async => await deleteDatabase('gymvision.db');

  static openDb() async {
    int amountOfMigrations = migrationScripts.length;
    database = openDatabase(
      join(await getDatabasesPath(), 'gymvision.db'),
      version: amountOfMigrations,
      onCreate: (db, version) async {
        Batch batch = db.batch();
        initialDbCreate(batch);

        for (int i = 1; i <= amountOfMigrations; i++) {
          batch.execute(migrationScripts[i]!);
        }

        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        Batch batch = db.batch();

        for (int i = oldVersion + 1; i <= newVersion; i++) {
          batch.execute(migrationScripts[i]!);
        }

        await batch.commit();
      },
    );
  }

  static Future<Database> getDb({Database? existingDb}) async {
    if (existingDb != null) return existingDb;
    if (database == null) await openDb();
    return database!;
  }

  static void initialDbCreate(Batch batch) {
    batch.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            done INTEGER DEFAULT 0
          );

          CREATE TABLE workout_categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workoutId INTEGER NOT NULL,
            categoryShellId INTEGER NOT NULL
          );

          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            exerciseType INTEGER NOT NULL,
            muscleGroup INTEGER NOT NULL,
            equipment INTEGER,
            split INTEGER,
            isDouble INTEGER DEFAULT 0,
            isCustom INTEGER DEFAULT 0
          );

          CREATE TABLE workout_sets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workoutId INTEGER NOT NULL,
            exerciseId INTEGER,
            done INTEGER DEFAULT 0,
            weight REAL,
            reps INTEGER,
            lastUpdated TEXT NOT NULL
          );

          CREATE TABLE flavour_texts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT
          );

          CREATE TABLE flavour_text_schedules(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            flavourTextId INTEGER NOT NULL,
            date TEXT NOT NULL,
            dismissed INTEGER NOT NULL DEFAULT 0
          );

          CREATE TABLE user_settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            theme TEXT
          );

          INSERT INTO user_settings(id, theme) VALUES (1, "system");
        ''');

    batch.execute(getInsertExercisesSql());
  }

  static updateExercises() async {
    final db = await getDb();
    final insertSql = getInsertExercisesSql();

    await db.delete('exercises');
    await db.rawInsert(insertSql);
  }

  static String getInsertExercisesSql() {
    var buffer = StringBuffer();

    buffer.writeln('INSERT INTO exercises');
    buffer.writeln('VALUES');

    final exercises = DataHelper.getDefaultExercises();
    final length = exercises.length;

    for (int i = 0; i < length; i++) {
      final ex = exercises[i];
      buffer.writeln(
        '(${ex.id}, "${ex.name}", ${ex.exerciseType.index}, ${ex.muscleGroup.index}, ${ex.equipment.index}, ${ex.split.index}, ${ex.isDouble ? 1 : 0})${i == length - 1 ? ';' : ','}',
      );
    }

    return buffer.toString();
  }

  static restartDbWhilePersistingData() async {
    final db = await getDb();
    var workouts = db.query('workouts');
    var categories = db.query('workout_categories');
    var sets = db.query('workout_sets');
  }
}
