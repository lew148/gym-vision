import 'package:drift/drift.dart';
import 'package:gymvision/db/converters/duration_converter.dart';
import 'package:gymvision/db/column_mixins.dart';
import 'package:gymvision/db/migrations.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/static_data/enums.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [
  DriftSettings,
  DriftBodyweights,
  DriftFlavourTextSchedules,
  DriftNotes,
  DriftWorkouts,
  DriftWorkoutCategories,
  DriftWorkoutExercises,
  DriftWorkoutSets,
  DriftSchedules,
  DriftScheduleItems,
  DriftScheduleCategories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => migrations.length + 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          final now = DateTime.now();
          await into(driftSettings).insert(
            DriftSettingsCompanion(
              updatedAt: Value(now),
              createdAt: Value(now),
              theme: const Value(UserTheme.system),
            ),
          );
        },
        onUpgrade: (m, from, to) async {
          // apply all migrations between from and to
          for (var i = from - 1; i < to - 1; i++) {
            await migrations[i](m);
          }
        },
      );
}

class DriftSettings extends Table with CoreColumns {
  @override
  String get tableName => 'settings';

  TextColumn get theme => textEnum<UserTheme>()();
  TextColumn get intraSetRestTimer => text().map(const DurationConverter()).nullable()();
}

class DriftBodyweights extends Table with CoreColumns {
  @override
  String get tableName => 'bodyweight';

  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();
  TextColumn get units => text()();
}

class DriftFlavourTextSchedules extends Table with CoreColumns {
  @override
  String get tableName => 'flavour_text_schedule';

  IntColumn get flavourTextId => integer()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
}

class DriftNotes extends Table with CoreColumns {
  @override
  String get tableName => 'note';

  TextColumn get objectId => text()();
  TextColumn get type => textEnum<NoteType>()();
  TextColumn get note => text()();
}

class DriftWorkouts extends Table with CoreColumns {
  @override
  String get tableName => 'workout';

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get exerciseOrder => text()();
}

class DriftWorkoutCategories extends Table with CoreColumns {
  @override
  String get tableName => 'workout_category';

  IntColumn get workoutId => integer().references(DriftWorkouts, #id)();
  TextColumn get category => textEnum<Category>()();
}

class DriftWorkoutExercises extends Table with CoreColumns {
  @override
  String get tableName => 'workout_exercise';

  IntColumn get workoutId => integer().references(DriftWorkouts, #id)();
  TextColumn get exerciseIdentifier => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get setOrder => text()();
}

class DriftWorkoutSets extends Table with CoreColumns {
  @override
  String get tableName => 'workout_set';

  IntColumn get workoutExerciseId => integer().references(DriftWorkoutExercises, #id)();

  // weight fields
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer().nullable()();

  // cardio fields
  TextColumn get time => text().map(const DurationConverter()).nullable()();
  RealColumn get distance => real().nullable()();
  IntColumn get calsBurned => integer().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class DriftSchedules extends Table with CoreColumns {
  @override
  String get tableName => 'schedule';

  TextColumn get name => text()();
  TextColumn get type => textEnum<ScheduleType>()();
  BoolColumn get active => boolean()();
  DateTimeColumn get startDate => dateTime()();
}

class DriftScheduleItems extends Table with CoreColumns {
  @override
  String get tableName => 'schedule_item';

  IntColumn get scheduleId => integer().references(DriftSchedules, #id)();
  IntColumn get itemOrder => integer()();
}

class DriftScheduleCategories extends Table with CoreColumns {
  @override
  String get tableName => 'schedule_category';

  IntColumn get scheduleItemId => integer().references(DriftScheduleItems, #id)();
  TextColumn get category => textEnum<Category>()();
}
