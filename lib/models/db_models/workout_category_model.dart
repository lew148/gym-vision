import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutCategoryModel {
  static Future<List<WorkoutCategory>> getWorkoutCategoriesByWorkout(int workoutId) async {
    final db = DatabaseHelper.db;
    return (await (db.select(db.driftWorkoutCategories)..where((wc) => wc.workoutId.equals(workoutId))).get())
        .map((wc) => wc.toObject())
        .toList();
  }

  static setWorkoutCategories(int workoutId, List<Category> categories) async {
    final existingCategories = await getWorkoutCategoriesByWorkout(workoutId);
    final newCategories = categories;

    if (existingCategories.isNotEmpty) {
      for (var ec in existingCategories) {
        if (categories.contains(ec.category)) {
          newCategories.remove(ec.category);
        } else {
          await delete(ec.id!);
        }
      }
    }

    for (var category in newCategories) {
      await insert(WorkoutCategory(
        workoutId: workoutId,
        category: category,
      ));
    }
  }

  static Future<int> insert(WorkoutCategory wc) async {
    final db = DatabaseHelper.db;
    var now = DateTime.now();
    return await db.into(db.driftWorkoutCategories).insert(DriftWorkoutCategoriesCompanion.insert(
          createdAt: Value(now),
          updatedAt: Value(now),
          workoutId: wc.workoutId,
          category: wc.category,
        ));
  }

  static Future<bool> delete(int id) async {
    final db = DatabaseHelper.db;
    await (db.delete(db.driftWorkoutCategories)..where((wc) => wc.id.equals(id))).go();
    return true;
  }
}
