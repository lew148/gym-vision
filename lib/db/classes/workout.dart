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

  String getDateString() {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    }

    if (date.day == now.day + 1 &&
        date.month == now.month + 1 &&
        date.year == now.year + 1) {
      return 'Tomorrow';
    }

    if (date.day == now.day - 1 &&
        date.month == now.month - 1 &&
        date.year == now.year - 1) {
      return 'Yesterday';
    }

    return DateFormat('EEEE, d MMM').format(date);
  }

  bool isSameDayAs(DateTime otherDate) =>
      date.day == otherDate.day &&
      date.month == otherDate.month &&
      date.year == otherDate.year;

  bool isToday() {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String getTimeString() => DateFormat('Hm').format(date);
}
