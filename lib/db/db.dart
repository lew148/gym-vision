import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database>? database;

  openDb() async {
    // await deleteDatabase('gymvision.db');
    database = openDatabase(
      join(await getDatabasesPath(), 'gymvision.db'),
      version: 1,
      onUpgrade: (db, oldVersion, newVersion) async { },
      onCreate: (db, version) async {
        Batch batch = db.batch();

        batch.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL
          );
        ''');

        batch.execute('''
          CREATE TABLE workout_categories(
            id INTEGER PRIMARY KEY,
            workoutId INTEGER,
            categoryId INTEGER
          );
        ''');

        batch.execute('''
          CREATE TABLE workout_exercises(
            id INTEGER PRIMARY KEY,
            workoutId INTEGER,
            exerciseId INTEGER,
            weight REAL,
            reps INTEGER,
            sets INTEGER,
            done INTEGER DEFAULT 0
          );
        ''');

        batch.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY,
            name TEXT,
            emoji TEXT
          );
        ''');

        batch.execute('''
          INSERT INTO categories(id, name, emoji)
          VALUES
            (1, "Shoulders", "🪨"),
            (2, "Chest", "🍒"),
            (3, "Back", "🎒"),
            (4, "Biceps", "💪"),
            (5, "Triceps", "🔱"),
            (6, "Core", "🍫"),
            (7, "Hamstrings & Glutes", "🍑"),
            (8, "Quadriceps & Calves", "🦿");
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
          CREATE TABLE user_settings(
            id INTEGER PRIMARY KEY,
            theme TEXT
          );
        ''');

        batch.execute('''
          INSERT INTO user_settings(id, theme) VALUES (1, "system");
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
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY,
            categoryId INTEGER,
            name TEXT,
            weight REAL,
            max REAL DEFAULT 0.00,
            reps INTEGER,
            isSingle INTEGER 
          );
        ''');

        // Shoulders
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (1, 1, "Shoulder Press", 0, 0, 0, 1),
            (2, 1, "Plate Steering Wheel Raise", 0, 0, 0, 1),
            (3, 1, "Dumbbell Shrug", 0, 0, 0, 0),
            (4, 1, "Cable Delt Raise", 0, 0, 0, 0),
            (5, 1, "Cable Front Delt Raise", 0, 0, 0, 0),
            (6, 1, "Dumbbell Delt Raise", 0, 0, 0, 0),
            (7, 1, "Dumbbell Shoulder Press", 0, 0, 0, 0),
            (8, 1, "Horizontal Rotator Cuff", 0, 0, 0, 0),
            (9, 1, "Vertical Rotator Cuff", 0, 0, 0, 0),
            (10, 1, "Cable Face Pull", 0, 0, 0, 1),
            (11, 1, "Roller Coaster", 0, 0, 0, 1),
            (12, 1, "Barbell Raise", 0, 0, 0, 1),
            (13, 1, "Plated Shoulder Press", 0, 0, 0, 0),
            (14, 1, "Dumbbell Rear Delt Skis", 0, 0, 0, 0);
        ''');

        // Chest
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (15, 2, "Plated Chest Press", 0, 0, 0, 0),
            (16, 2, "Cable Low Fly", 0, 0, 0, 0),
            (17, 2, "Cable Mid Fly", 0, 0, 0, 0),
            (18, 2, "Cable High Fly", 0, 0, 0, 0),
            (19, 2, "Incline Dumbbell Press", 0, 0, 0, 0),
            (20, 2, "Bench Press", 0, 0, 0, 1),
            (21, 2, "Wide Push Up", 0, 0, 0, 1),
            (22, 2, "Dumbbell Fly", 0, 0, 0, 0),
            (23, 2, "Pectoral Machine", 0, 0, 0, 1);
        ''');

        // Back
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (24, 3, "Cable Diverging Row", 0, 0, 0, 0),
            (25, 3, "Straight Arm Pulldown", 0, 0, 0, 1),
            (26, 3, "Lat Pulldown", 0, 0, 0, 1),
            (27, 3, "Small Lat Pulldown", 0, 0, 0, 1),
            (28, 3, "T-Row Bar", 0, 0, 0, 1),
            (29, 3, "Low Row", 0, 0, 0, 0),
            (30, 3, "Cable Row", 0, 0, 0, 1),
            (31, 3, "Cable High Row", 0, 0, 0, 1),
            (32, 3, "Bench Row", 0, 0, 0, 0),
            (33, 3, "Bent-Over Barbell Row", 0, 0, 0, 1),
            (34, 3, "Pull Up", 0, 0, 0, 1),
            (35, 3, "Assisted Pull Up", 0, 0, 0, 1),
            (36, 3, "Cable Kneeling Pull", 0, 0, 0, 0),
            (37, 3, "Reverse Fly Machine", 0, 0, 0, 1),
            (38, 3, "Starfish", 0, 0, 0, 0);
        ''');

        // Biceps
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (39, 4, "Seated Dubbell Bicep Curl", 0, 0, 0, 0),
            (40, 4, "W-Shape Dubbell Bicep Curl", 0, 0, 0, 0),
            (41, 4, "Barbell Bicep Curl", 0, 0, 0, 1),
            (42, 4, "Chin Up", 0, 0, 0, 1),
            (43, 4, "Assisted Chin Up", 0, 0, 0, 1),
            (44, 4, "Turning Dumbbell Bicep Curl", 0, 0, 0, 0),
            (45, 4, "Cable Bicep Curl", 0, 0, 0, 1),
            (46, 4, "Cable Bicep Curl", 0, 0, 0, 0),
            (47, 4, "Bench Hammer Curl", 0, 0, 0, 0);
        ''');

        // Triceps
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (48, 5, "Cable Tricep Curl", 0, 0, 0, 1),
            (49, 5, "Cable Tricep Curl", 0, 0, 0, 0),
            (50, 5, "Dumbbell Triceps Dip", 0, 0, 0, 0),
            (51, 5, "Seated Triceps Lift", 0, 0, 0, 0),
            (52, 5, "Barbell Triceps Curl", 0, 0, 0, 1),
            (53, 5, "Triceps Dip", 0, 0, 0, 1);
        ''');

        // Core
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (54, 6, "Ab Crunch Machine", 0, 0, 0, 1),
            (55, 6, "Suspended Leg Lifts", 0, 0, 0, 1),
            (56, 6, "Oblique Lift", 0, 0, 0, 0),
            (57, 6, "Bench Sit-Ups", 0, 0, 0, 1),
            (58, 6, "Russian Twists", 0, 0, 0, 1),
            (59, 6, "Cable Ab Crunch", 0, 0, 0, 1),
            (60, 6, "Vaccums", 0, 0, 0, 1);
        ''');

        // Hamstrings & Glutes
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (61, 7, "Cable Abductor Lift", 0, 0, 0, 0),
            (62, 7, "Adductor Machine", 0, 0, 0, 1),
            (63, 7, "Leg Curl", 0, 0, 0, 0),
            (64, 7, "Sumo Squat", 0, 0, 0, 1),
            (65, 7, "Deadlift", 0, 0, 0, 1),
            (66, 7, "Bar RDL -> Squat", 0, 0, 0, 1),
            (67, 7, "Hip Thrusts", 0, 0, 0, 1),
            (68, 7, "Prone Leg Curl", 0, 0, 0, 1);
        ''');

        // Quadriceps & Calves
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (69, 8, "Hack Squat", 0, 0, 0, 1),
            (70, 8, "Squat", 0, 0, 0, 1),
            (71, 8, "Elevated Front-Leg Lunge", 0, 0, 0, 0),
            (72, 8, "Leg Press", 0, 0, 0, 1),
            (73, 8, "Calf Press", 0, 0, 0, 1),
            (74, 8, "Leg Extension", 0, 0, 0, 1),
            (75, 8, "Leg Extension", 0, 0, 0, 0),
            (76, 8, "Elevated Heel Squat", 0, 0, 0, 1),
            (77, 8, "Raised Calf Bar Press", 0, 0, 0, 0);
        ''');

        await batch.commit();
      },
    );
  }

  Future<Database> getDb() async {
    if (database == null) await openDb();
    return database!;
  }
}
