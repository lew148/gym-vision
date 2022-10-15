import 'package:gymvision/db/classes/flavour_text.dart';
import 'package:gymvision/db/db.dart';

class FlavourTextHelper {
  Future<FlavourText> getRandomFlavourText() async {
    final db = await DatabaseHelper().getDb();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM flavour_texts ORDER BY RANDOM() LIMIT 1;');

    return FlavourText(
      id: maps[0]['id'],
      message: maps[0]['message'],
    );
  }
}