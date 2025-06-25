import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutTemplateExercise extends DatabaseObject {
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

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutTemplateId': workoutTemplateId,
        'exerciseIdentifier': exerciseIdentifier,
      };

  bool isCardio() => exercise?.type == ExerciseType.cardio;
}
