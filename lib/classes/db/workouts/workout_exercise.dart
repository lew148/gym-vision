import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutExercise extends DBO {
  final int workoutId;
  final String exerciseIdentifier;
  bool done; // for zero-set WorkoutExercises
  String setOrder;

  // non-db props
  Workout? workout;
  Exercise? exercise;
  List<WorkoutSet>? workoutSets;

  WorkoutExercise({
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.workoutId,
    this.workout,
    required this.exerciseIdentifier,
    this.exercise,
    this.done = false,
    required this.setOrder,
    this.workoutSets,
  });

  bool isCardio() => exercise?.type == ExerciseType.cardio;
  bool isDone() => workoutSets == null || workoutSets!.isEmpty ? done : !(workoutSets!.any((ws) => !ws.done));
}
