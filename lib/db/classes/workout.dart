import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/globals.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;

  bool? done;

  List<WorkoutCategory>? workoutCategories;
  List<WorkoutExercise>? workoutExercises;

  Workout({
    this.id,
    required this.date,
    this.done,
    this.workoutExercises,
    this.workoutCategories,
  });

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toString()};

  String getTimeString() => DateFormat('Hm').format(date);

  String getDateAndTimeString() => '${getDateString(date)} @ ${getTimeString()}';

  bool isInFuture() => dateIsInFuture(date);
}
