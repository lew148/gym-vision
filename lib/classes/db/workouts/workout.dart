import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise_ordering.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:intl/intl.dart';

class Workout extends DatabaseObject {
  DateTime date;

  // non-db props
  bool done;
  List<WorkoutCategory>? workoutCategories;
  WorkoutExerciseOrdering? exerciseOrdering;
  List<WorkoutExercise>? workoutExercises;
  bool? isEmpty;

  Workout({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.date,
    this.done = false,
    this.workoutCategories,
    this.exerciseOrdering,
    this.workoutExercises,
    this.isEmpty,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'date': date.toString(),
      };

  String getTimeStr() => DateFormat('Hm').format(date);
  bool isInFuture() => dateIsInFuture(date);
  String getDateStr() =>
      date.year != DateTime.now().year ? DateFormat(dmyFormat).format(date) : DateFormat(dmFormat).format(date);

  String getDateOrDayStr() {
    final now = DateTime.now();
    if (isToday(date, now: now)) return 'Today';
    if (isTomorrow(date, now: now)) return 'Tomorrow';
    if (isYesterday(date, now: now)) return 'Yesterday';
    return getDateStr();
  }

  List<Category> getCategories() => workoutCategories?.map((wc) => wc.category).toList() ?? [];
  List<WorkoutExercise> getWorkoutExercises() => workoutExercises ?? [];
  List<WorkoutSet> getSets() =>
      workoutExercises?.where((we) => we.workoutSets != null).expand((we) => we.workoutSets!).toList() ?? [];

  String getWorkoutTitle() {
    if (isInFuture()) return 'Planned Workout 📍';
    if (date.hour >= 4 && date.hour < 12) return 'Morning Workout 🌅';
    if (date.hour >= 12 && date.hour < 18) return 'Afternoon Workout ☀️';
    if (date.hour >= 18 && date.hour < 22) return 'Evening Workout 🌆';
    if (date.hour < 24) return 'Night Workout 🌙';
    return 'Workout';
  }

  bool getIsEmpty() => workoutExercises?.isEmpty ?? isEmpty ?? true;
}
