import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutTemplate extends DBO {
  String name;
  String categories; // in order
  String exerciseOrder;

  // non-db props
  List<WorkoutTemplateExercise>? workoutTemplateExercises;
  Note? note;

  WorkoutTemplate({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.name,
    this.categories = '',
    this.exerciseOrder = '',
    this.workoutTemplateExercises,
    this.note,
  });

  void setCategories(List<Category> cats) =>
      categories = cats.map((c) => EnumHelper.enumToString(c)).toList().join(',');

  List<Category> getCategories() =>
      categories.split(',').map((c) => EnumHelper.stringToEnum(c, Category.values)).whereType<Category>().toList();

  List<WorkoutTemplateExercise> getWorkoutTemplateExercises() => workoutTemplateExercises ?? [];
}
