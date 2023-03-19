import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class ExercisesHelper {
  static Future<List<Exercise>> getExercisesForCategory(int categoryId) async =>
      await getExercises(whereString: 'categoryId = $categoryId');

  static Future<List<Exercise>> getAllExercisesExcludingIds(
    List<int>? excludedExerciseIds,
    List<int>? categoryIds,
  ) async {
    StringBuffer? whereString;

    if (excludedExerciseIds != null) {
      whereString = StringBuffer(
        'exercises.id NOT IN (${excludedExerciseIds.join(',')})',
      );
    }

    if (categoryIds != null) {
      if (whereString == null) {
        whereString = StringBuffer();
      } else {
        whereString.write(' AND ');
      }

      whereString.write('exercises.categoryId IN (${categoryIds.join(',')})');
    }

    return await getExercises(whereString: whereString?.toString());
  }

  static Future<List<Exercise>> getExercises({String? whereString}) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        exercises.id,
        exercises.categoryId,
        exercises.name,
        exercises.weight,
        exercises.max,
        exercises.reps,
        exercises.isSingle,
        exercises.notes,
        categories.name AS categoryName,
        categories.emoji
      FROM exercises
      LEFT JOIN categories ON exercises.categoryId = categories.id
      ${whereString != null ? 'WHERE $whereString' : ''}
      ORDER BY exercises.name ASC;
    ''');

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
        notes: maps[i]['notes'] ?? '',
        category: maps[i]['categoryName'] == null
            ? null
            : Category(
                id: maps[i]['categoryId'],
                name: maps[i]['categoryName'],
                emoji: maps[i]['emoji'],
              ),
      ),
    );
  }

  static Future<Exercise> getExercise(int id) async {
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
      notes: map['notes'] ?? '',
    );
  }

  static Future<void> insertExercise(Exercise exercise) async {
    final db = await DatabaseHelper().getDb();
    await exerciseIsValidAndUnique(db, exercise);
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteExercise(int id) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateExercise(Exercise exercise) async {
    final db = await DatabaseHelper().getDb();
    await exerciseIsValidAndUnique(db, exercise);
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  static exerciseIsValidAndUnique(Database db, Exercise exercise) async {
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
