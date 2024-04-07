import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/db/helpers/user_exercise_details_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';

import '../../helpers/category_shell_helper.dart';

class ExercisesHelper {
  static Future<List<Exercise>> getExercisesByCategory({
    List<int>? categoryShellIds,
    List<int>? excludedExerciseIds,
  }) async {
    StringBuffer? whereString;

    if (categoryShellIds != null && categoryShellIds.isNotEmpty) {
      final shellDisplayNames =
          CategoryShellHelper.getCategoryShellsWithIds(categoryShellIds).map((e) => e.displayName).toList();
      final exerciseTypes =
          ExerciseType.values.where((e) => shellDisplayNames.contains(e.displayName)).map((e) => e.index).toList();
      final muscleGroups =
          MuscleGroup.values.where((e) => shellDisplayNames.contains(e.displayName)).map((e) => e.index).toList();
      final splits =
          ExerciseSplit.values.where((e) => shellDisplayNames.contains(e.displayName)).map((e) => e.index).toList();

      whereString = StringBuffer();
      var needsConnector = false;
      var needsTrailingParenthesis = false;
      const and = 'AND (';
      var connector = and;

      void applyConnector() {
        if (needsConnector) {
          if (connector == and) needsTrailingParenthesis = true;
          whereString!.write(' $connector ');
        }
        needsConnector = true;
        connector = "OR";
      }

      if (excludedExerciseIds != null && excludedExerciseIds.isNotEmpty) {
        whereString.write('exercises.id NOT IN (${excludedExerciseIds.join(',')})');
        needsConnector = true;
      }

      if (exerciseTypes.isNotEmpty) {
        applyConnector();
        whereString.write('exercises.exerciseType IN (${exerciseTypes.join(',')})');
      }

      if (muscleGroups.isNotEmpty || splits.contains(ExerciseSplit.arms.index)) {
        applyConnector();

        if (splits.contains(ExerciseSplit.arms.index)) {
          // "arms" split selected (add arms muscle groups)
          muscleGroups.addAll([MuscleGroup.biceps.index, MuscleGroup.triceps.index, MuscleGroup.forearms.index]);
          distinctIntList(muscleGroups);
          splits.remove(ExerciseSplit.arms.index);
        }

        whereString.write('exercises.muscleGroup IN (${muscleGroups.join(',')})');
      }

      if (splits.isNotEmpty) {
        applyConnector();
        whereString.write('exercises.split IN (${splits.join(',')})');
      }

      if (needsTrailingParenthesis) whereString.write(" )");
    }

    return await getExercises(
      whereString: whereString.toString(),
      includeUserDetails: true,
    );
  }

  static Future<List<Exercise>> getExercises({
    String? whereString,
    bool includeUserDetails = false,
    bool includeRecentUses = false,
  }) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        exercises.id,
        exercises.name,
        exercises.exerciseType,
        exercises.muscleGroup,
        exercises.equipment,
        exercises.split,
        exercises.isDouble
      FROM exercises
      ${whereString != null && whereString != "" ? 'WHERE $whereString' : ''}
      ORDER BY exercises.name ASC;
    ''');

    List<Exercise> exercises = [];

    for (var map in maps) {
      exercises.add(
        Exercise(
          id: map['id'],
          name: map['name'],
          exerciseType: ExerciseType.values.elementAt(map['exerciseType']),
          muscleGroup: MuscleGroup.values.elementAt(map['muscleGroup']),
          equipment: ExerciseEquipment.values.elementAt(map['equipment']),
          split: ExerciseSplit.values.elementAt(map['split']),
          isDouble: map['isDouble'] == 1,
          userExerciseDetails: includeUserDetails
              ? await UserExerciseDetailsHelper.getUserDetailsForExercise(
                  exerciseId: map['id'],
                  includeRecentUses: includeRecentUses,
                )
              : null,
        ),
      );
    }

    return exercises;
  }

  static Future<Exercise> getExercise({
    required int id,
    bool includeUserDetails = false,
    bool includeRecentUses = false,
  }) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    final map = maps[0];
    return Exercise(
      id: id,
      name: map['name'],
      exerciseType: ExerciseType.values.elementAt(map['exerciseType']),
      muscleGroup: MuscleGroup.values.elementAt(map['muscleGroup']),
      equipment: ExerciseEquipment.values.elementAt(map['equipment']),
      split: ExerciseSplit.values.elementAt(map['split']),
      isDouble: map['isDouble'] == 1,
      userExerciseDetails: includeUserDetails
          ? await UserExerciseDetailsHelper.getUserDetailsForExercise(
              exerciseId: map['id'],
              includeRecentUses: includeRecentUses,
            )
          : null,
    );
  }

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
