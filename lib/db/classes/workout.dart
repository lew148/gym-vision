import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/globals.dart';
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

  String getDateString() {
    final today = DateTime.now();
    if (areSameDay(today, date)) {
      return 'Today';
    }

    if (date.day == today.day + 1 &&
        date.month == today.month &&
        date.year == today.year) {
      return 'Tomorrow';
    }

    if (date.day == today.day - 1 &&
        date.month == today.month &&
        date.year == today.year) {
      return 'Yesterday';
    }

    return date.year == today.year
        ? DateFormat('EEEE, d MMM').format(date)
        : DateFormat('EEEE, d MMM yyyy').format(date);
  }

  String getTimeString() => DateFormat('Hm').format(date);
}
