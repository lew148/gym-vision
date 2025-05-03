import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/workout_category.dart';
import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/classes/db/workout_exercise_ordering.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:intl/intl.dart';

class Workout extends DatabaseObject {
  DateTime date;

  // non-db props
  bool done;
  List<WorkoutCategory>? workoutCategories;
  WorkoutExerciseOrdering? exerciseOrdering;
  List<WorkoutExercise>? workoutExercses;
  bool? isEmpty;

  Workout({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.date,
    this.done = false,
    this.workoutCategories,
    this.exerciseOrdering,
    this.workoutExercses,
    this.isEmpty,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'date': date.toString(),
      };

  Workout fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'],
        updatedAt: DateTime.parse(map['updatedAt']),
        createdAt: DateTime.parse(map['createdAt']),
        date: DateTime.parse(map['date']),
      );

  String getTimeStr() => DateFormat('Hm').format(date);
  bool isInFuture() => dateIsInFuture(date);
  String getDateStr() =>
      date.year != DateTime.now().year ? DateFormat(dmyFormat).format(date) : DateFormat(dmFormat).format(date);

  List<Category> getCategories() => workoutCategories?.map((wc) => wc.category).toList() ?? [];
  List<WorkoutExercise> getWorkoutExercises() => workoutExercses ?? [];
  List<WorkoutSet> getSets() =>
      workoutExercses?.where((we) => we.workoutSets != null).expand((we) => we.workoutSets!).toList() ?? [];

  String getWorkoutTitle() {
    if (isInFuture()) return 'Planned Workout 📍';
    if (date.hour > 3 && date.hour < 12) return 'Morning Workout 🌅';
    if (date.hour > 12 && date.hour < 18) return 'Afternoon Workout ☀️';
    if (date.hour > 18 && date.hour < 22) return 'Evening Workout 🌆';
    if (date.hour < 24) return 'Night Workout 🌙';
    return 'Workout';
  }

  bool getIsEmpty() => workoutExercses?.isEmpty ?? isEmpty ?? true;
}
