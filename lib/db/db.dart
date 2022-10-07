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
            sets INTEGER
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
            (1, 1, "Shoulder Press", 60, 0, 10, 1),
            (2, 1, "Plate Steering Wheel Raise", 15, 0, 12, 1),
            (3, 1, "Dumbbell Shrug", 34, 0, 12, 0),
            (4, 1, "Cable Delt Raise", 7.5, 0, 10, 0),
            (5, 1, "Cable Front Delt Raise", 10, 0, 8, 0),
            (6, 1, "Dumbbell Delt Raise", 14, 0, 10, 0),
            (7, 1, "Dumbbell Shoulder Press", 30, 0, 10, 0),
            (8, 1, "Horizontal Rotator Cuff", 14, 0, 10, 0),
            (9, 1, "Vertical Rotator Cuff", 12, 0, 10, 0),
            (10, 1, "Cable Face Pull", 37.5, 42.5, 12, 1),
            (11, 1, "Roller Coaster", 10, 0, 30, 1),
            (12, 1, "Barbell Raise", 30, 0, 8, 1),
            (13, 1, "Plated Shoulder Press", 50, 0, 8, 0),
            (14, 1, "Dumbbell Rear Delt Skis", 20, 0, 10, 0);
        ''');

        // Chest
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (15, 2, "Plated Chest Press", 40, 45, 10, 0),
            (16, 2, "Cable Low Fly", 12.5, 0, 10, 0),
            (17, 2, "Cable Mid Fly", 10, 0, 10, 0),
            (18, 2, "Cable High Fly", 12.5, 15, 10, 0),
            (19, 2, "Incline Dumbbell Press", 30, 34, 10, 0),
            (20, 2, "Bench Press", 70, 80, 8, 1),
            (21, 2, "Wide Push Up", 0, 0, 20, 1),
            (22, 2, "Dumbbell Fly", 16, 0, 10, 0),
            (23, 2, "Pectoral Machine", 15, 0, 10, 1);
        ''');

        // Back
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (24, 3, "Cable Diverging Row", 5, 10, 10, 0),
            (25, 3, "Straight Arm Pulldown", 20, 22.5, 10, 1),
            (26, 3, "Lat Pulldown", 55, 0, 8, 1),
            (27, 3, "Small Lat Pulldown", 50, 55, 10, 1),
            (28, 3, "T-Row Bar", 40, 0, 10, 1),
            (29, 3, "Low Row", 45, 50, 10, 0),
            (30, 3, "Cable Row", 50, 55, 10, 1),
            (31, 3, "Cable High Row", 42.5, 0, 10, 1),
            (32, 3, "Bench Row", 28, 0, 10, 0),
            (33, 3, "Bent-Over Barbell Row", 45, 0, 10, 1),
            (34, 3, "Pull Up", 0, 0, 4, 1),
            (35, 3, "Assisted Pull Up", -21, 0, 8, 1),
            (36, 3, "Cable Kneeling Pull", 12.5, 0, 12, 0),
            (37, 3, "Reverse Fly Machine", 10, 0, 8, 1),
            (38, 3, "Starfish", 2, 0, 8, 0);
        ''');

        // Biceps
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (39, 4, "Seated Dubbell Bicep Curl", 12, 14, 8, 0),
            (40, 4, "W-Shape Dubbell Bicep Curl", 14, 0, 8, 0),
            (41, 4, "Barbell Bicep Curl", 30, 0, 10, 1),
            (42, 4, "Chin Up", 0, 0, 5, 1),
            (43, 4, "Assisted Chin Up", -14, 0, 8, 1),
            (44, 4, "Turning Dumbbell Bicep Curl", 12, 0, 8, 0),
            (45, 4, "Cable Bicep Curl", 20, 0, 10, 1),
            (46, 4, "Cable Bicep Curl", 10, 0, 10, 0),
            (47, 4, "Bench Hammer Curl", 16, 18, 10, 0);
        ''');

        // Triceps
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (48, 5, "Cable Tricep Curl", 20, 0, 10, 1),
            (49, 5, "Cable Tricep Curl", 10, 0, 10, 0),
            (50, 5, "Dumbbell Triceps Dip", 14, 0, 10, 0),
            (51, 5, "Seated Triceps Lift", 22, 0, 10, 0),
            (52, 5, "Barbell Triceps Curl", 35, 0, 10, 1),
            (53, 5, "Triceps Dip", 0, 0, 12, 1);
        ''');

        // Core
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (54, 6, "Ab Crunch Machine", 30, 0, 10, 1),
            (55, 6, "Suspended Leg Lifts", 0, 0, 12, 1),
            (56, 6, "Oblique Lift", 25, 0, 8, 0),
            (57, 6, "Bench Sit-Ups", 10, 0, 10, 1),
            (58, 6, "Russian Twists", 25, 0, 12, 1),
            (59, 6, "Cable Ab Crunch", 45, 47.5, 10, 1),
            (60, 6, "Vaccums", 0, 0, 12, 1);
        ''');

        // Hamstrings & Glutes
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (61, 7, "Cable Abductor Lift", 5, 7.5, 12, 0),
            (62, 7, "Adductor Machine", 35, 0, 10, 1),
            (63, 7, "Leg Curl", 12, 0, 12, 0),
            (64, 7, "Sumo Squat", 70, 80, 8, 1),
            (65, 7, "Deadlift", 50, 0, 10, 1),
            (66, 7, "Bar RDL -> Squat", 25, 30, 8, 1),
            (67, 7, "Hip Thrusts", 90, 0, 10, 1),
            (68, 7, "Prone Leg Curl", 30, 35, 10, 1);
        ''');

        // Quadriceps & Calves
        batch.execute('''
          INSERT INTO exercises(id, categoryId, name, weight, max, reps, isSingle)
          VALUES
            (69, 8, "Hack Squat", 70, 80, 10, 1),
            (70, 8, "Squat", 70, 80, 10, 1),
            (71, 8, "Elevated Front-Leg Lunge", 18, 20, 10, 0),
            (72, 8, "Leg Press", 220, 0, 10, 1),
            (73, 8, "Calf Press", 150, 0, 8, 1),
            (74, 8, "Leg Extension", 60, 0, 10, 1),
            (75, 8, "Leg Extension", 30, 0, 10, 0),
            (76, 8, "Elevated Heel Squat", 50, 60, 10, 1),
            (77, 8, "Raised Calf Bar Press", 10, 0, 8, 0);
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
