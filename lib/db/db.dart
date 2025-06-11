import 'package:gymvision/db/migrations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
          for (var s in migrationScripts[i]!) {
            batch.execute(s);
          }
        }

        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        Batch batch = db.batch();

        for (int i = oldVersion + 1; i <= newVersion; i++) {
          for (var s in migrationScripts[i]!) {
            batch.execute(s);
          }
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
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        date TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE workout_exercise_orderings(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        workoutId INTEGER NOT NULL,
        positions TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE workout_categories(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        workoutId INTEGER NOT NULL,
        category TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE workout_exercises(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        workoutId INTEGER NOT NULL,
        exerciseIdentifier TEXT NOT NULL,
        done INTEGER DEFAULT 0
      );
    ''');

    batch.execute('''
      CREATE TABLE workout_sets(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        workoutExerciseId INTEGER NOT NULL,
        done INTEGER DEFAULT 0,
        weight REAL,
        reps INTEGER,
        time TEXT,
        distance REAL,
        calsBurned INTEGER
      );
    ''');

    batch.execute('''
      CREATE TABLE flavour_text_schedules(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        flavourTextId INTEGER NOT NULL,
        date TEXT NOT NULL,
        dismissed INTEGER DEFAULT 0
      );
    ''');

    batch.execute('''
      CREATE TABLE bodyweights(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        units TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        theme TEXT
      );
    ''');

    final now = DateTime.now().toString();
    batch.execute('INSERT INTO user_settings(id, updatedAt, createdAt, theme) VALUES (1, "$now", "$now", "system");');
  }
}
