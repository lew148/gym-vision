import 'package:gymvision/db/custom_database.dart';
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

  static Future<CustomDatabase> getDb() async {
    if (database == null) await openDb();
    return await CustomDatabase.loadDb(database!);
  }

  static void initialDbCreate(Batch batch) {
    // keep to one SQL function per batch.execute()

    batch.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        date TEXT NOT NULL,
        endDate TEXT
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
      CREATE TABLE schedules(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        active INTEGER DEFAULT 0,
        startDate TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE schedule_items(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        scheduleId INTEGER NOT NULL,
        itemOrder INTEGER NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE schedule_categories(
        id INTEGER PRIMARY KEY,
        updatedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        scheduleItemId INTEGER NOT NULL,
        category TEXT NOT NULL
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

  static Future<bool> tableExists(String table) async {
    var db = await DatabaseHelper.getDb();
    var maps = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table';");
    return maps.isNotEmpty;
  }

  static Future<bool> resetWhilePersistingData() async {
    var workouts = [];
    var workoutExerciseOrderings = [];
    var workoutCategories = [];
    var workoutExercises = [];
    var workoutSets = [];
    var schedules = [];
    var scheduleItems = [];
    var scheduleCategories = [];
    var flavourTextSchedules = [];
    var bodyweights = [];
    var userSettings = [];

    try {
      var prevDb = await getDb();

      // in order of initialDbCreate()
      if (await tableExists('workouts')) workouts = await prevDb.query('workouts');
      if (await tableExists('workout_exercise_orderings')) {
        workoutExerciseOrderings = await prevDb.query('workout_exercise_orderings');
      }

      if (await tableExists('workout_categories')) {
        workoutCategories = await prevDb.query('workout_categories');
      }

      if (await tableExists('workout_exercises')) {
        workoutExercises = await prevDb.query('workout_exercises');
      }

      if (await tableExists('workout_sets')) workoutSets = await prevDb.query('workout_sets');
      if (await tableExists('schedules')) schedules = await prevDb.query('schedules');
      if (await tableExists('schedule_items')) scheduleItems = await prevDb.query('schedule_items');
      if (await tableExists('schedule_categories')) {
        scheduleCategories = await prevDb.query('schedule_categories');
      }

      if (await tableExists('flavour_text_schedules')) {
        flavourTextSchedules = await prevDb.query('flavour_text_schedules');
      }

      if (await tableExists('bodyweights')) bodyweights = await prevDb.query('bodyweights');
      if (await tableExists('user_settings')) userSettings = await prevDb.query('user_settings');
    } catch (ex) {
      return false;
    }

    try {
      await deleteDb();
      var newDb = await getDb();

      for (var w in workouts) {
        await newDb.insert('workouts', {
          'id': w['id'],
          'updatedAt': w['updatedAt'],
          'createdAt': w['createdAt'],
          'date': w['date'],
          'endDate': w['endDate'],
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

      for (var s in schedules) {
        await newDb.insert('schedules', {
          'id': s['id'],
          'updatedAt': s['updatedAt'],
          'createdAt': s['createdAt'],
          'name': s['name'],
          'type': s['type'],
          'active': s['active'],
          'startDate': s['startDate'] ?? DateTime.now().toString(),
        });
      }

      for (var si in scheduleItems) {
        await newDb.insert('schedule_items', {
          'id': si['id'],
          'updatedAt': si['updatedAt'],
          'createdAt': si['createdAt'],
          'scheduleId': si['scheduleId'],
          'itemOrder': si['itemOrder'],
        });
      }

      for (var sc in scheduleCategories) {
        await newDb.insert('schedule_categories', {
          'id': sc['id'],
          'updatedAt': sc['updatedAt'],
          'createdAt': sc['createdAt'],
          'scheduleItemId': sc['scheduleItemId'],
          'category': sc['category'],
        });
      }

      return true;
    } catch (ex) {
      return false;
    }
  }
}
