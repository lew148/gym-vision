import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database>? database;

  openDb() async {
    // await deleteDatabase('gymvision.db');
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

  Future<Database> getDb() async {
    if (database == null) await openDb();
    return database!;
  }

  void initialDbCreate(Batch batch) {
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
          reps INTEGER
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
            isDouble INTEGER DEFAULT 0,
            isCustom INTEGER DEFAULT 0
          );
        ''');

    batch.execute('''
          CREATE TABLE user_exercise_details(
            id INTEGER PRIMARY KEY,
            exerciseId INTEGER NOT NULL,
            notes TEXT,
            prId INT,
            lastId INT
          );
        ''');

    // Shoulders
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (1, "Shoulder Press", 2, 7, 4, 0, 1, 0),
            (2, "Steering Wheel Raise", 2, 7, 7, 0, 0, 0),
            (3, "Shrug", 2, 7, 4, 1, 1, 0),
            (4, "Dumbbell Delt Raise", 2, 7, 4, 0, 1, 0),
            (5, "Cable Delt Raise", 2, 7, 4, 0, 1, 0),
            (6, "Front Delt Raise", 2, 7, 3, 0, 1, 0),
            (7, "External Rotation", 2, 7, 4, 1, 1, 0),
            (8, "Barbell Raise", 2, 7, 1, 0, 0, 0),
            (9, "Plated Shoulder Press", 2, 7, 7, 0, 1, 0),
            (10, "Rear Delt Skis", 2, 7, 1, 1, 1, 0);
        ''');

    // Chest
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (11, "Plated Chest Press", 2, 2, 7, 0, 1, 0),
            (12, "Cable Low Fly", 2, 2, 3, 0, 1, 0),
            (13, "Cable Fly", 2, 2, 3, 0, 1, 0),
            (14, "Cable High Fly", 2, 2, 3, 0, 1, 0),
            (15, "Dumbbell Low Fly", 2, 2, 4, 0, 1, 0),
            (16, "Dumbbell Fly", 2, 2, 4, 0, 1, 0),
            (17, "Flat Chest Press", 2, 2, 4, 0, 1, 0),
            (18, "Incline Chest Press", 2, 2, 4, 0, 1, 0),
            (19, "Flat Bench Press", 2, 2, 7, 0, 0, 0),
            (20, "Incline Bench Press", 2, 2, 7, 0, 0, 0),
            (21, "Pectoral Machine", 2, 2, 6, 0, 0, 0);
        ''');

    // Biceps
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (22, "Seated Dumbbell Bicep Curl", 2, 1, 4, 1, 1, 0),
            (23, "W Bicep Curl", 2, 1, 4, 1, 1, 0),
            (24, "Barbell Bicep Curl", 2, 1, 1, 1, 0, 0),
            (25, "Chin Up", 2, 1, 2, 1, 0, 0),
            (26, "Cable Bicep Curl", 2, 1, 3, 1, 0, 0),
            (27, "Single Cable Bicep Curl", 2, 1, 3, 1, 1, 0),
            (28, "Hammer Curl", 2, 1, 7, 1, 0, 0),
            (29, "Single Hammer Curl", 2, 1, 4, 1, 1, 0),
            (30, "Preacher Curl", 2, 1, 7, 1, 0, 0);
        ''');

    // Back
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (31, "Diverging Row", 2, 0, 3, 1, 1, 0),
            (32, "Straight Arm Pulldown", 2, 0, 3, 1, 0, 0),
            (33, "Lat Pulldown", 2, 0, 6, 1, 0, 0),
            (34, "Small Lat Pulldown", 2, 0, 6, 1, 0, 0),
            (35, "Low Row", 2, 0, 7, 1, 0, 0),
            (36, "Single Row", 2, 0, 7, 1, 1, 0),
            (37, "Bench Row", 2, 0, 4, 1, 1, 0),
            (38, "Pull Up", 2, 0, 2, 1, 0, 0);
        ''');

    // Triceps
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (39, "Tricep Pulldown", 2, 8, 3, 1, 0, 0),
            (40, "Single Tricep Pulldown", 2, 8, 3, 1, 1, 0),
            (41, "Dumbbell Triceps Extension", 2, 8, 4, 0, 0, 0),
            (42, "Single Dumbbell Tricep Extension", 2, 8, 4, 0, 1, 0),
            (43, "Triceps Dip", 2, 8, 2, 0, 0, 0),
            (44, "Skull Crushers", 2, 8, 1, 0, 0, 0);
        ''');

    // Core
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (45, "Crunch Machine", 2, 3, 6, 1, 0, 0),
            (46, "Suspended Leg Lifts", 2, 3, 2, 1, 0, 0),
            (47, "Oblique Lift", 2, 3, 5, 1, 0, 0),
            (48, "Weighted Sit-Ups", 2, 3, 7, 1, 0, 0),
            (49, "Russian Twists", 2, 3, 7, 1, 0, 0),
            (50, "Cable Crunch", 2, 3, 3, 1, 0, 0);
        ''');

    // Hamstrings & Glutes
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (51, "Cable Abductor Lift", 2, 5, 3, 2, 1, 0),
            (52, "Adductor Machine", 2, 5, 6, 2, 0, 0),
            (53, "Leg Curl", 2, 5, 6, 2, 0, 0),
            (54, "Single Leg Curl", 2, 5, 6, 2, 1, 0),
            (55, "Sumo Squat", 2, 5, 7, 2, 0, 0),
            (56, "Deadlift", 2, 5, 7, 2, 0, 0),
            (57, "RDL", 2, 5, 4, 2, 1, 0),
            (58, "Hip Thrusts", 2, 5, 7, 2, 0, 0),
            (59, "Prone Leg Curl", 2, 5, 6, 2, 0, 0);
        ''');

    // Quadriceps & Calves
    batch.execute('''
          INSERT INTO exercises(id, name, exerciseType, muscleGroup, equipment, split, isDouble, isCustom)
          VALUES
            (60, "Hack Squat", 2, 6, 7, 2, 0, 0),
            (61, "Squat", 2, 6, 7, 2, 0, 0),
            (62, "Lunge", 2, 6, 7, 2, 0, 0),
            (63, "Dumbbell Lunge", 2, 6, 4, 2, 1, 0),
            (64, "Leg Press", 2, 6, 7, 2, 0, 0),
            (65, "Calf Press", 2, 6, 7, 2, 0, 0),
            (66, "Leg Extension", 2, 6, 6, 2, 0, 0),
            (67, "Single Leg Extension", 2, 6, 6, 2, 1, 0),
            (68, "Calf Raise", 2, 6, 7, 2, 0, 0),
            (69, "Single Calf Raise", 2, 6, 7, 2, 1, 0);
        ''');
  }
}
