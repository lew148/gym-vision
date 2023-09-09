import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:intl/intl.dart';

class Workout {
  int? id;
  DateTime date;
  bool done;

  List<WorkoutCategory>? workoutCategories;
  List<WorkoutSet>? workoutSets;

  Workout({
    this.id,
    required this.date,
    this.done = false,
    this.workoutCategories,
    this.workoutSets,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toString(),
        'done': done,
      };

  String getTimeString() => DateFormat('Hm').format(date);

  String getDateAndTimeString() => '${getDateString(date)} @ ${getTimeString()}';

  bool isInFuture() => dateIsInFuture(date);
}
