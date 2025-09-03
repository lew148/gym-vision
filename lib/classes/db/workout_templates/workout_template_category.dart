import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutTemplateCategory extends DBO {
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

  String getCategoryDisplayName() => category.displayName;
  String? getCategoryEnumString() => EnumHelper.enumToString(category);
}
