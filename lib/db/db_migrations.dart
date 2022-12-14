class MigrationsHelper {
  static Map<int, String> migrationScripts = {
    1: '', // base version
    2: '''
        CREATE TABLE flavour_texts(
          id INTEGER PRIMARY KEY,
          message TEXT
        );
      ''',
    3: '''
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
      ''',
    4: '''
        CREATE TABLE user_settings(
          id INTEGER PRIMARY KEY,
          theme TEXT
        );
      ''',
    5: '''
        INSERT INTO user_settings(id, theme)
          VALUES
            (1, "system");
      ''',
    6: '''
        ALTER TABLE workout_exercises ADD COLUMN weight REAL;
      ''',
    7: '''
        ALTER TABLE workout_exercises ADD COLUMN reps INTEGER;
      ''',
    8: '''
        CREATE TABLE flavour_text_schedules(
          id INTEGER PRIMARY KEY,
          flavourTextId INTEGER NOT NULL,
          date TEXT NOT NULL,
          dismissed INTEGER NOT NULL DEFAULT 0
        );
      ''',
    9: '''
        ALTER TABLE workout_exercises ADD COLUMN done INTEGER DEFAULT 0;
        ''',
  };

  static migrationsQty() => migrationScripts.length;
}
