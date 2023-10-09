import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_exercise_ordering.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;

  bool done;
  List<WorkoutCategory>? workoutCategories;
  List<WorkoutSet>? workoutSets;
  WorkoutExerciseOrdering? ordering;

  Workout({
    this.id,
    required this.date,
    this.done = false,
    this.workoutCategories,
    this.workoutSets,
    this.ordering,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toString(),
      };

  String getTimeString() => DateFormat('Hm').format(date);

  String getDateAndTimeString() => '${getDateString(date)} @ ${getTimeString()}';

  bool isInFuture() => dateIsInFuture(date);
}
