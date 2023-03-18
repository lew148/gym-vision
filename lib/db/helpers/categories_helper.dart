import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/db.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesHelper {
  Future<List<Category>> getCategories({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: where,
      whereArgs: whereArgs,
    );
    return List.generate(
      maps.length,
      (i) => Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        emoji: maps[i]['emoji'],
      ),
    );
  }

  static Future<Category> getCategory(int id) async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'ID = ?',
      whereArgs: [id],
    );
    return Category(
      id: maps[0]['id'],
      name: maps[0]['name'],
      emoji: maps[0]['emoji'],
    );
  }

  static Future<void> insertCategory(Category category) async {
    final db = await DatabaseHelper().getDb();
    await categoryIsValidAndUnique(db, category);
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCategory(int id) async {
    final db = await DatabaseHelper().getDb();
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateCategory(Category category) async {
    final db = await DatabaseHelper().getDb();
    await categoryIsValidAndUnique(db, category);
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static categoryIsValidAndUnique(Database db, Category category) async {
    if (category.name.isEmpty) throw Exception('Category must have a name.');

    final numWithSameName = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(name)
      FROM categories
      WHERE lower(name) = lower('${category.name}')
      AND id is not ${category.id};
    '''));

    if (numWithSameName != null && numWithSameName > 0) {
      throw Exception('Category with this name already exists.');
    }
  }
}
