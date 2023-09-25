import 'package:gymvision/helpers/data_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database>? database;

  static deleteDb() async => await deleteDatabase('gymvision.db');

  static openDb() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'gymvision.db'),
      version: 1,
      onCreate: (db, version) async {
        Batch batch = db.batch();
        initialDbCreate(batch);
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
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            done INTEGER DEFAULT 0
          );
        ''');

    batch.execute('''
          CREATE TABLE workout_categories(
            id INTEGER PRIMARY KEY,
            workoutId INTEGER NOT NULL,
            categoryShellId INTEGER NOT NULL
          );
        ''');

    batch.execute('''
        CREATE TABLE workout_sets(
          id INTEGER PRIMARY KEY,
          workoutId INTEGER NOT NULL,
          exerciseId INTEGER,
          done INTEGER DEFAULT 0,
          weight REAL,
          reps INTEGER,
          lastUpdated TEXT NOT NULL
        );
      ''');

    batch.execute('''
          CREATE TABLE flavour_texts(
            id INTEGER PRIMARY KEY,
            message TEXT
          );
        ''');

    batch.execute('''
           INSERT INTO flavour_texts(id, message)
            VALUES
              (1, "Make sure you are drinking enough water!"),
              (2, "Rest days are as important as workout days!"),
              (3, "Giving up kills gains!"),
              (4, "Remember to warm-up and cool-down!"),
              (5, "Even the smallest workouts help you grow!"),
              (6, "Mindset is half of the struggle!"),
              (7, "Your limits arent real. Only in the mind!"),
              (8, "Have a good workout!"),
              (9, "Routine is the best form of discipline!"),
              (10, "Be extra careful when hitting PRs!"),
              (11, "If you keep showing up, you'll be unbeatable!");
        ''');

    batch.execute('''
          CREATE TABLE flavour_text_schedules(
            id INTEGER PRIMARY KEY,
            flavourTextId INTEGER NOT NULL,
            date TEXT NOT NULL,
            dismissed INTEGER NOT NULL DEFAULT 0
          );
        ''');

    batch.execute('''
          CREATE TABLE user_settings(
            id INTEGER PRIMARY KEY,
            theme TEXT
          );
        ''');

    batch.execute('''
          INSERT INTO user_settings(id, theme) VALUES (1, "system");
        ''');

    batch.execute('''
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            exerciseType INTEGER NOT NULL,
            muscleGroup INTEGER NOT NULL,
            equipment INTEGER,
            split INTEGER,
            isDouble INTEGER DEFAULT 0
          );
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
}
