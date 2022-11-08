import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/db.dart';

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
}
