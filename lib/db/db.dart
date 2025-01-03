import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/helpers/bodyweight_helper.dart';
import 'package:gymvision/db/helpers/workout_exercise_orderings_helper.dart';
import 'package:gymvision/db/helpers/workout_sets_helper.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/db/legacy_sql.dart';
import 'package:gymvision/db/migrations.dart';
import 'package:gymvision/helpers/data_helper.dart';
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
        date TEXT NOT NULL
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
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        exerciseType INTEGER NOT NULL,
        muscleGroup INTEGER NOT NULL,
        equipment INTEGER,
        split INTEGER,
        uniAndBiLateral INTEGER DEFAULT 0
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
        single INTEGER DEFAULT 0,
        time TEXT,
        distance REAL,
        calsBurned INTEGER,
        lastUpdated TEXT NOT NULL
      );
    ''');

    batch.execute('''
      CREATE TABLE workout_exercise_orderings(
        id INTEGER PRIMARY KEY,
        workoutId INTEGER NOT NULL,
        positions TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE flavour_texts(
        id INTEGER PRIMARY KEY,
        message TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE flavour_text_schedules(
        id INTEGER PRIMARY KEY,
        flavourTextId INTEGER NOT NULL,
        date TEXT NOT NULL,
        dismissed INTEGER DEFAULT 0
      );
    ''');

    batch.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        theme TEXT,
        firstUse TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE bodyweights(
        id INTEGER PRIMARY KEY,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        units TEXT NOT NULL
      );
    ''');

    batch.execute(
      'INSERT INTO user_settings(id, theme, firstUse) VALUES (1, "system", "${DateTime.now().toString()}");',
    );

    batch.execute(getFlavourTextInsertSql());
    batch.execute(getExerciseInsertSql());
  }

  static updateExercises() async {
    final db = await getDb();
    final insertSql = getExerciseInsertSql();

    await db.delete('exercises');
    await db.rawInsert(insertSql);
  }

  static String getExerciseInsertSql() {
    var buffer = StringBuffer();
    final exercises = DataHelper.getDefaultExercises();
    final length = exercises.length;

    buffer.writeln('INSERT INTO exercises');
    buffer.writeln('VALUES');

    for (int i = 0; i < length; i++) {
      final ex = exercises[i];
      buffer.writeln(
        '(${ex.id}, "${ex.name}", ${ex.exerciseType.index}, ${ex.muscleGroup.index}, ${ex.equipment.index}, ${ex.split.index}, ${ex.uniAndBiLateral ? 1 : 0})${i == length - 1 ? ';' : ','}',
      );
    }

    return buffer.toString();
  }

  static String getFlavourTextInsertSql() {
    var buffer = StringBuffer();
    final fts = DataHelper.getFlavourTexts();
    final length = fts.length;

    buffer.writeln('INSERT INTO flavour_texts');
    buffer.writeln('VALUES');

    for (int i = 0; i < length; i++) {
      final ft = fts[i];
      buffer.writeln('(${ft.id}, "${ft.message}")${i == length - 1 ? ';' : ','}');
    }

    return buffer.toString();
  }

  static restartDbWhilePersistingData() async {
    var workoutsAndCategories = await LegacySql.getWorkoutsLegacy();
    var sets = await LegacySql.getWorkoutSets();
    var bws = await LegacySql.getBodyweights();

    await deleteDb();
    await openDb();

    for (var w in workoutsAndCategories) {
      await WorkoutsHelper.insertWorkout(w);

      if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty) {
        await WorkoutsHelper.setWorkoutCategories(
          w.id!,
          w.workoutCategories!.map((wc) => wc.categoryShellId).toList(),
        );
      }

      if (w.ordering != null) {
        await WorkoutExerciseOrderingsHelper.insertWorkoutExerciseOrdering(w.ordering!);
      }
    }

    for (var s in sets) {
      await WorkoutSetsHelper.addSetToWorkout(
        WorkoutSet(
          id: s.id,
          exerciseId: s.exerciseId,
          workoutId: s.workoutId,
          weight: s.weight,
          reps: s.reps,
          done: s.done,
          single: s.single,
          calsBurned: s.calsBurned,
          distance: s.distance,
          time: s.time,
        ),
      );
    }

    for (var b in bws) {
      await BodyweightHelper.insertBodyweight(Bodyweight(
        date: b.date,
        weight: b.weight,
        units: b.units,
      ));
    }
  }
}
