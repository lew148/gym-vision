import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/helpers/workout_category_helper.dart';

class WorkoutCategory {
  int? id;
  int? userId;
  final int workoutId;
  Workout? workout;
  final int categoryShellId;

  WorkoutCategory({
    this.id,
    this.userId,
    required this.workoutId,
    this.workout,
    required this.categoryShellId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'categoryShellId': categoryShellId,
      };

  String getDisplayName() =>
      WorkoutCategoryHelper.getCategoryShells().firstWhere((s) => s.id == categoryShellId).displayName;
}
