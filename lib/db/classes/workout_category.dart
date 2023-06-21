import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/classes/workout.dart';

import '../../enums.dart';

class WorkoutCategory {
  int? id;
  int? userId;
  final int workoutId;
  Workout? workout;
  WorkoutCategoryType type;
  MuscleGroup? muscleGroup;
  ExerciseSplit? split;
  String? value;

  // old
  final int? categoryId;
  Category? category;

  WorkoutCategory({
    this.id,
    this.userId,
    required this.workoutId,
    this.workout,
    required this.type,
    this.muscleGroup,
    this.split,
    this.value,

    // old
    this.categoryId,
    this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'workoutId': workoutId,
        'type': type,
        'muscleGroup': muscleGroup,
        'split': split,
        'value': value,
      };

  String getDisplayName() {
    switch (type) {
      case WorkoutCategoryType.muscleGroup:
      case WorkoutCategoryType.split:
        var buffer = StringBuffer();

        switch (muscleGroup) {
          case MuscleGroup.back:
            buffer.write("🎒 Back");
            break;
          case MuscleGroup.biceps:
            buffer.write("💪 Biceps");
            break;
          case MuscleGroup.chest:
            buffer.write("🍒 Chest");
            break;
          case MuscleGroup.core:
            buffer.write("🍎 Core");
            break;
          case MuscleGroup.forearms:
            buffer.write("🪵 Forearms");
            break;
          case MuscleGroup.hamstringsAndGlutes:
            buffer.write("🍑 Hamstrings & Glutes");
            break;
          case MuscleGroup.quadsAndCalves:
            buffer.write("🦵 Quads & Calves");
            break;
          case MuscleGroup.shoulders:
            buffer.write("🪨 Shoulders");
            break;
          case MuscleGroup.triceps:
            buffer.write("🔱 Triceps");
            break;
          case MuscleGroup.other:
            buffer.write("❔ Other");
            break;
          case null:
            break;
        }

        switch (split) {
          case ExerciseSplit.push:
            buffer.write("➡️ Push");
            break;
          case ExerciseSplit.pull:
            buffer.write("⬅️ Pull");
            break;
          case ExerciseSplit.legs:
            buffer.write("🦵 Legs");
            break;
          case ExerciseSplit.other:
            buffer.write( "❔ Other");
            break;
          case null:
            break;
        }

        return buffer.toString();
      case WorkoutCategoryType.cardio:
        return "💦 Cardio";
      case WorkoutCategoryType.Class:
        return "🍀 ${value == null ? "" : "$value "}Class";
      case WorkoutCategoryType.other:
        return "❔ ${value ?? "Other"}";
    }
  }
}
