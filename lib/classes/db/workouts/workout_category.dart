import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutCategory extends DBO {
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

  String getCategoryDisplayName() => category.displayName;
  String getCategoryDisplayNamePlain() => category.displayNamePlain;
  String? getCategoryEnumString() => EnumHelper.enumToString(category);
}
