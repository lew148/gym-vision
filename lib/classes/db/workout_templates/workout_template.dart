import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_category.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';

class WorkoutTemplate extends DatabaseObject {
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

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'name': name,
      };
}
