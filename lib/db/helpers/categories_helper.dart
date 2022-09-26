import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/db.dart';

class CategoriesHelper {
  Future<List<Category>> getCategories() async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> categoriesMaps = await db.query('categories');
    return List.generate(
      categoriesMaps.length,
      (i) => Category(
        id: categoriesMaps[i]['id'],
        name: categoriesMaps[i]['name'],
      ),
    );
  }
}
