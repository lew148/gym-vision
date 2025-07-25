import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutCategoryModel {
  static Future<List<WorkoutCategory>?> getWorkoutCategoriesForWorkout(int workoutId) async {
    final db = await DatabaseHelper.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_categories',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );

    if (maps.isEmpty) return null;
    return maps
        .map(
          (m) => WorkoutCategory(
            id: m['id'],
            updatedAt: tryParseDateTime(m['updatedAt']),
            createdAt: tryParseDateTime(m['createdAt']),
            workoutId: m['workoutId'],
            category: stringToEnum<Category>(m['category'], Category.values)!,
          ),
        )
        .toList();
  }

  static setWorkoutCategories(int workoutId, List<Category> categories) async {
    final db = await DatabaseHelper.getDb();
    final existingCategories = await getWorkoutCategoriesForWorkout(workoutId);
    final newCategories = categories;

    if (existingCategories != null && existingCategories.isNotEmpty) {
      for (var ec in existingCategories) {
        if (categories.contains(ec.category)) {
          newCategories.remove(ec.category);
        } else {
          await removeWorkoutCategory(ec.id!);
        }
      }
    }

    final now = DateTime.now();

    for (var category in newCategories) {
      await db.insert(
        'workout_categories',
        WorkoutCategory(
          workoutId: workoutId,
          category: category,
          createdAt: now,
          updatedAt: now,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static removeWorkoutCategory(int id) async {
    final db = await DatabaseHelper.getDb();
    await db.delete(
      'workout_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
