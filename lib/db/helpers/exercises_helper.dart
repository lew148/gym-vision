import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class ExercisesHelper {
  Future<List<Exercise>> getExercisesForCategory(int categoryId) async =>
      await getExercises(where: 'categoryId = ?', whereArgs: [categoryId]);

  Future<List<Exercise>> getAllExercises() async => await getExercises();

  Future<List<Exercise>> getAllExercisesExcludingIds(
      List<int> excludedExerciseIds) async {
    return await getExercises(
      where:
          'id NOT IN (${List.filled(excludedExerciseIds.length, '?').join(',')})',
      whereArgs: excludedExerciseIds,
    );
  }

  Future<List<Exercise>> getExercises({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return List.generate(
      maps.length,
      (i) => Exercise(
        id: maps[i]['id'],
        categoryId: maps[i]['categoryId'],
        name: maps[i]['name'],
        weight: maps[i]['weight'],
        max: maps[i]['max'],
        reps: maps[i]['reps'],
        isSingle: maps[i]['isSingle'] == 1, // saved in db as integer (0 or 1)
      ),
    );
  }

  Future<Exercise> getExercise(int id) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    final map = maps[0];
    return Exercise(
      id: id,
      categoryId: map['categoryId'],
      name: map['name'],
      weight: map['weight'],
      max: map['max'],
      reps: map['reps'],
      isSingle: map['isSingle'] == 1,
    );
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await DatabaseHelper().getDb();
    exerciseIsValidAndUnique(db, exercise);
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExercise(int id) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await DatabaseHelper().getDb();
    await exerciseIsValidAndUnique(db, exercise);
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  exerciseIsValidAndUnique(Database db, Exercise exercise) async {
    if (exercise.name.isEmpty) throw Exception('Exercise must have a name.');

    final numWithSameName = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(name)
      FROM exercises
      WHERE lower(name) = lower('${exercise.name}')
      AND id is not ${exercise.id};
    '''));

    if (numWithSameName != null && numWithSameName > 0) {
      throw Exception('Exercise with this name already exists.');
    }
  }
}
