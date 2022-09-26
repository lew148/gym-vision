import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class ExercisesHelper {
  Future<List<Exercise>> getExercisesForCategory(int categoryId) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return List.generate(
      maps.length,
      (i) => Exercise(
        id: maps[i]['id'],
        categoryId: categoryId,
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
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }
}
