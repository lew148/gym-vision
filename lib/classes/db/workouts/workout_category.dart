import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutCategory extends DatabaseObject {
  int workoutId;
  Category category;

  // non-db props
  Workout? workout;

  WorkoutCategory({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.workoutId,
    required this.category,
    this.workout,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutId': workoutId,
        'category': getCategoryEnumString(),
      };

  String getCategoryDisplayName() => category.displayName;
  String getCategoryDisplayNamePlain() => category.displayNamePlain;
  String? getCategoryEnumString() => enumToString(category);
}
