import 'package:gymvision/db/migrations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database>? database;

  static deleteDb() async {
    await deleteDatabase('gymvision.db');
    database = null;
  }

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
    // keep to one SQL function per batch.execute()

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

  static Future<bool> resetWhilePersistingData() async {
    try {
      var prevDb = await getDb();

      // in order of initialDbCreate()
      var workouts = await prevDb.query('workouts');
      var workoutExerciseOrderings = await prevDb.query('workout_exercise_orderings');
      var workoutCategories = await prevDb.query('workout_categories');
      var workoutExercises = await prevDb.query('workout_exercises');
      var workoutSets = await prevDb.query('workout_sets');
      var flavourTextSchedules = await prevDb.query('flavour_text_schedules');
      var bodyweights = await prevDb.query('bodyweights');
      var userSettings = await prevDb.query('user_settings');

      await deleteDb();
      var newDb = await getDb();

      for (var w in workouts) {
        await newDb.insert('workouts', {
          'id': w['id'],
          'updatedAt': w['updatedAt'],
          'createdAt': w['createdAt'],
          'date': w['date'],
        });
      }

      for (var weo in workoutExerciseOrderings) {
        await newDb.insert('workout_exercise_orderings', {
          'id': weo['id'],
          'updatedAt': weo['updatedAt'],
          'createdAt': weo['createdAt'],
          'workoutId': weo['workoutId'],
          'positions': weo['positions'],
        });
      }

      for (var wc in workoutCategories) {
        await newDb.insert('workout_categories', {
          'id': wc['id'],
          'updatedAt': wc['updatedAt'],
          'createdAt': wc['createdAt'],
          'workoutId': wc['workoutId'],
          'category': wc['category'],
        });
      }

      for (var we in workoutExercises) {
        await newDb.insert('workout_exercises', {
          'id': we['id'],
          'updatedAt': we['updatedAt'],
          'createdAt': we['createdAt'],
          'workoutId': we['workoutId'],
          'exerciseIdentifier': we['exerciseIdentifier'],
          'done': we['done'],
        });
      }

      for (var ws in workoutSets) {
        await newDb.insert('workout_sets', {
          'id': ws['id'],
          'updatedAt': ws['updatedAt'],
          'createdAt': ws['createdAt'],
          'workoutExerciseId': ws['workoutExerciseId'],
          'done': ws['done'],
          'weight': ws['weight'],
          'reps': ws['reps'],
          'time': ws['time'],
          'distance': ws['distance'],
          'calsBurned': ws['calsBurned'],
        });
      }

      for (var fts in flavourTextSchedules) {
        await newDb.insert('flavour_text_schedules', {
          'id': fts['id'],
          'updatedAt': fts['updatedAt'],
          'createdAt': fts['createdAt'],
          'flavourTextId': fts['flavourTextId'],
          'date': fts['date'],
          'dismissed': fts['dismissed'],
        });
      }

      for (var bw in bodyweights) {
        await newDb.insert('bodyweights', {
          'id': bw['id'],
          'updatedAt': bw['updatedAt'],
          'createdAt': bw['createdAt'],
          'weight': bw['weight'],
          'date': bw['date'],
          'units': bw['units'],
        });
      }

      for (var us in userSettings) {
        // new record is made in initialDbCreate()
        await newDb.update('user_settings', {
          'id': us['id'],
          'updatedAt': us['updatedAt'],
          'createdAt': us['createdAt'],
          'theme': us['theme'],
        });
      }

      return true;
    } catch (ex) {
      return false;
    }
  }
}
