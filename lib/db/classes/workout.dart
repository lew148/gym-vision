import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;

  List<WorkoutExercise>? workoutExercises;
  List<WorkoutCategory>? categories;
  List<String>? categoryStrings;

  Workout({
    this.id,
    required this.date,
    this.workoutExercises,
    this.categories,
    this.categoryStrings,
  });

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toString()};

  String getDateString() => DateFormat.yMEd().format(date);
}
