import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutTemplateExercise extends DBO {
  int workoutTemplateId;
  String exerciseIdentifier;
  String setOrder;

  // non-db props
  WorkoutTemplate? workoutTemplate;
  Exercise? exercise;
  List<WorkoutTemplateSet>? workoutTemplateSets;

  WorkoutTemplateExercise({
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.workoutTemplateId,
    this.workoutTemplate,
    required this.exerciseIdentifier,
    this.exercise,
    required this.setOrder,
    this.workoutTemplateSets,
  });

  List<WorkoutTemplateSet> getSets() => workoutTemplateSets ?? [];

  bool isCardio() => exercise?.type == ExerciseType.cardio;
}
