import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutTemplateExercise extends DBO {
  final int workoutTemplateId;
  final String exerciseIdentifier;

  // non-db props
  WorkoutTemplate? workoutTemplate;
  Exercise? exercise;

  WorkoutTemplateExercise({
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.workoutTemplateId,
    this.workoutTemplate,
    required this.exerciseIdentifier,
    this.exercise,
  });

  bool isCardio() => exercise?.type == ExerciseType.cardio;
}
