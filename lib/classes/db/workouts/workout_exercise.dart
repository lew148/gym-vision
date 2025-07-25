import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutExercise extends DatabaseObject {
  final int workoutId;
  final String exerciseIdentifier;
  bool done;

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
    this.workoutSets,
    this.done = false,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutId': workoutId,
        'exerciseIdentifier': exerciseIdentifier,
        'done': done ? 1 : 0,
      };

  bool isCardio() => exercise?.type == ExerciseType.cardio;
}
