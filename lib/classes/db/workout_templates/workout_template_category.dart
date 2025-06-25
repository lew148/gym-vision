import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutTemplateCategory extends DatabaseObject {
  int workoutTemplateId;
  Category category;

  // non-db props
  WorkoutTemplate? workoutTemplate;

  WorkoutTemplateCategory({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.workoutTemplateId,
    required this.category,
    this.workoutTemplate,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutTemplateId': workoutTemplateId,
        'category': getCategoryEnumString(),
      };

  String getCategoryDisplayName() => category.displayName;
  String? getCategoryEnumString() => enumToString(category);
}
