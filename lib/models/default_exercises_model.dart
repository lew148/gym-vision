import 'package:collection/collection.dart';
import 'package:gymvision/models/exercise_details_model.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/data/default_exercises.dart';
import 'package:gymvision/static_data/enums.dart';

class DefaultExercisesModel {
  static List<Exercise> getExercises({
    List<Category>? categories,
    List<String>? excludedExerciseIds,
  }) {
    var exercises = defaultExercises;

    if (categories != null && categories.isNotEmpty) {
      exercises = exercises.where((e) => e.categories.any(categories.contains)).toSet();
    }

    if (excludedExerciseIds != null && excludedExerciseIds.isNotEmpty) {
      exercises = exercises.where((e) => !excludedExerciseIds.contains(e.identifier)).toSet();
    }

    var list = exercises.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  static Future<Exercise?> getExerciseWithDetails({required String identifier, bool includeRecentUses = false}) async {
    var exercise = defaultExercises.firstWhereOrNull((e) => e.identifier == identifier);
    if (exercise == null) return null;

    exercise.exerciseDetails = await ExerciseDetailsModel.getExerciseDetails(
      exerciseIdentifier: identifier,
      includeRecentUses: includeRecentUses,
    );

    return exercise;
  }

  static Exercise? getExerciseByIdentifier(String identifier) =>
      defaultExercises.firstWhereOrNull((e) => e.identifier == identifier);

  // static Future<void> insertExercise(Exercise exercise) async {
  //   final db = await DatabaseHelper().getDb();
  //   await exerciseIsValidAndUnique(db, exercise);
  //   await db.insert(
  //     'exercises',
  //     exercise.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // static Future<void> deleteExercise(int id) async {
  //   final db = await DatabaseHelper().getDb();
  //   await db.delete(
  //     'exercises',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // static Future<void> updateExercise(Exercise exercise) async {
  //   final db = await DatabaseHelper().getDb();
  //   await exerciseIsValidAndUnique(db, exercise);
  //   await db.update(
  //     'exercises',
  //     exercise.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [exercise.id],
  //   );
  // }

  // static exerciseIsValidAndUnique(Database db, Exercise exercise) async {
  //   if (exercise.name.isEmpty) throw Exception('Exercise must have a name.');

  //   final numWithSameName = Sqflite.firstIntValue(await db.rawQuery('''
  //     SELECT COUNT(name)
  //     FROM exercises
  //     WHERE lower(name) = lower('${exercise.name}')
  //     AND id is not ${exercise.id};
  //   '''));

  //   if (numWithSameName != null && numWithSameName > 0) {
  //     throw Exception('Exercise with this name already exists.');
  //   }
  // }
}
