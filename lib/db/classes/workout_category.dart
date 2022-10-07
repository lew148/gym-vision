import 'package:gymvision/db/classes/category.dart';

class WorkoutCategory {
  int? id;
  final int workoutId;
  final int categoryId;

  Category? category;

  WorkoutCategory({
    this.id,
    required this.workoutId,
    required this.categoryId,
    this.category,
  });

  Map<String, dynamic> toMap() =>
      {'id': id, 'workoutId': workoutId, 'categoryId': categoryId};
}
