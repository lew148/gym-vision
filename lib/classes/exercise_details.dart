import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';

class ExerciseDetails {
  String exerciseIdentifier;
  WorkoutSet? max;
  WorkoutSet? last;
  List<WorkoutExercise>? workoutExercises;

  ExerciseDetails({
    required this.exerciseIdentifier,
    this.max,
    this.last,
    this.workoutExercises,
  });
}
