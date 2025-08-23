import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutExercise extends DatabaseObject {
  final int workoutId;
  final String exerciseIdentifier;
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
    required this.setOrder,
    this.workoutSets,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutId': workoutId,
        'exerciseIdentifier': exerciseIdentifier,
        'setOrder': setOrder,
      };

  bool isCardio() => exercise?.type == ExerciseType.cardio;
  bool isDone() => workoutSets == null ? false : (workoutSets!.isEmpty ? false : !(workoutSets!.any((ws) => !ws.done)));
}
