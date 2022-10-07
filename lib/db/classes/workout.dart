import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;

  List<WorkoutCategory>? workoutCategories;
  List<WorkoutExercise>? workoutExercises;

  Workout({
    this.id,
    required this.date,
    this.workoutExercises,
    this.workoutCategories,
  });

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toString()};

  String getDateString() => DateFormat('EEEE, d MMM').format(date);

  String getTimeString() => DateFormat('Hm').format(date);
}
