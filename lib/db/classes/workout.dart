import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;

  // non-db fields
  List<WorkoutExercise>? exercises;
  List<WorkoutCategory>? categories;
  List<String>? categoryStrings;

  Workout({this.id, required this.date, this.exercises, this.categories, this.categoryStrings});

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toString()};

  String getDateString() => DateFormat.yMEd().format(date);
}
