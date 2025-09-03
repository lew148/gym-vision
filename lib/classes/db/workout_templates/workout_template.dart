import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_category.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';

class WorkoutTemplate extends DBO {
  String name;

  // non-db props
  List<WorkoutTemplateCategory>? workoutTemplateCategories;
  List<WorkoutTemplateExercise>? workoutTemplateExercises;
  // WorkoutExerciseOrdering? exerciseOrdering;

  WorkoutTemplate({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.name,
    this.workoutTemplateCategories,
    this.workoutTemplateExercises,
    // this.exerciseOrdering,
  });
}
