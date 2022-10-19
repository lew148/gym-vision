import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/workout.dart';

class WorkoutExercise {
  int? id;
  final int workoutId;
  final int exerciseId;
  int? sets;

  Workout? workout;
  Exercise? exercise;

  WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    this.sets,
    this.workout,
    this.exercise,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'sets': sets
      };
}
