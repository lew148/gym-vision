import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';

class WorkoutTemplateSet extends DBO {
  int workoutTemplateExerciseId;
  double? weight;
  int? reps;
  Duration? time;
  double? distance;
  int? calsBurned;

  // non-db props
  WorkoutTemplateExercise? workoutTemplateExercise;

  WorkoutTemplateSet({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.workoutTemplateExerciseId,
    this.weight,
    this.reps,
    this.time,
    this.distance,
    this.calsBurned,
    this.workoutTemplateExercise,
  });

  Exercise? getExercise() {
    if (workoutTemplateExercise == null) return null;
    if (workoutTemplateExercise!.exercise != null) return workoutTemplateExercise!.exercise;
    return DefaultExercisesModel.getExerciseByIdentifier(workoutTemplateExercise!.exerciseIdentifier);
  }

  WorkoutTemplate? getWorkoutTemplate() => workoutTemplateExercise?.workoutTemplate;
}
