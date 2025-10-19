import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:intl/intl.dart';

class Workout extends DBO {
  DateTime date;
  DateTime? endDate;
  String exerciseOrder;

  // non-db props
  List<WorkoutCategory>? workoutCategories;
  List<WorkoutExercise>? workoutExercises;

  WorkoutSummary? summary;

  Workout({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.date,
    required this.exerciseOrder,
    this.endDate,
    this.workoutCategories,
    this.workoutExercises,
    this.summary,
  });

  bool isFinished() => endDate != null;
  Duration getDuration() =>
      endDate == null ? DateTimeHelper.timeBetween(date, DateTime.now()) : DateTimeHelper.timeBetween(date, endDate!);

  String getTimeStr() => DateFormat(DateTimeHelper.hmFormat).format(date);
  bool isInFuture() => DateTimeHelper.isInFuture(date);

  List<Category> getCategories() => workoutCategories?.map((wc) => wc.category).toList() ?? [];
  List<WorkoutExercise> getWorkoutExercises() => workoutExercises ?? [];

  String getWorkoutTitle() {
    if (isInFuture()) return '📍 Planned Workout';
    if (date.hour >= 4 && date.hour < 12) return 'Morning Workout';
    if (date.hour >= 12 && date.hour < 18) return 'Afternoon Workout';
    if (date.hour >= 18 && date.hour < 22) return 'Evening Workout';
    if (date.hour < 24) return 'Night Workout';
    return 'Workout';
  }

  bool hasCategories() => workoutCategories != null && workoutCategories!.isNotEmpty;
}
