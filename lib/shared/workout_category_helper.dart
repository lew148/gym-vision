import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/enums.dart';

class WorkoutCategoryShell {
  int id;
  WorkoutCategoryType type;
  String displayName;

  WorkoutCategoryShell({
    required this.id,
    required this.type,
    required this.displayName,
  });
}

class WorkoutCategoryHelper {
  static String backDisplayName = "🎒 Back";
  static String bicepsDisplayName = "💪 Biceps";
  static String chestDisplayName = "🍒 Chest";
  static String coreDisplayName = "🍎 Core";
  static String forearmsDisplayName = "🪵 Forearms";
  static String hamstringsAndGlutesDisplayName = "🍑 Hamstrings & Glutes";
  static String quadsAndCalvesDisplayName = "🦵 Quads & Calves";
  static String shouldersDisplayName = "🪨 Shoulders";
  static String tricepsDisplayName = "🔱 Triceps";
  static String pushDisplayName = "➡️ Push";
  static String pullDisplayName = "⬅️ Pull";
  static String legsDisplayName = "🦵 Legs";
  static String cardioDisplayName = "💦 Cardio";
  static String classDisplayName = "🍀 Class";
  static String otherDisplayName = "❔ Other";

  static List<WorkoutCategoryShell> getCategoryShells() {
    List<WorkoutCategoryShell> list = [];
    list.addAll(getActivityCategoryShells());
    list.addAll(getSplitCategoryShells());
    list.addAll(getMuscleGroupCategoryShells());
    list.add(otherCategoryShell);
    return list;
  }

  static List<WorkoutCategoryShell> getActivityCategoryShells() => [
        WorkoutCategoryShell(id: 1, type: WorkoutCategoryType.cardio, displayName: cardioDisplayName),
        WorkoutCategoryShell(id: 2, type: WorkoutCategoryType.Class, displayName: classDisplayName),
      ];

  static List<WorkoutCategoryShell> getSplitCategoryShells() => [
        WorkoutCategoryShell(id: 3, type: WorkoutCategoryType.split, displayName: pushDisplayName),
        WorkoutCategoryShell(id: 4, type: WorkoutCategoryType.split, displayName: pullDisplayName),
        WorkoutCategoryShell(id: 5, type: WorkoutCategoryType.split, displayName: legsDisplayName),
      ];

  static List<WorkoutCategoryShell> getMuscleGroupCategoryShells() => [
        WorkoutCategoryShell(id: 6, type: WorkoutCategoryType.muscleGroup, displayName: backDisplayName),
        WorkoutCategoryShell(id: 7, type: WorkoutCategoryType.muscleGroup, displayName: bicepsDisplayName),
        WorkoutCategoryShell(id: 8, type: WorkoutCategoryType.muscleGroup, displayName: chestDisplayName),
        WorkoutCategoryShell(id: 9, type: WorkoutCategoryType.muscleGroup, displayName: coreDisplayName),
        WorkoutCategoryShell(id: 10, type: WorkoutCategoryType.muscleGroup, displayName: forearmsDisplayName),
        WorkoutCategoryShell(id: 11, type: WorkoutCategoryType.muscleGroup, displayName: hamstringsAndGlutesDisplayName),
        WorkoutCategoryShell(id: 12, type: WorkoutCategoryType.muscleGroup, displayName: quadsAndCalvesDisplayName),
        WorkoutCategoryShell(id: 13, type: WorkoutCategoryType.muscleGroup, displayName: shouldersDisplayName),
        WorkoutCategoryShell(id: 14, type: WorkoutCategoryType.muscleGroup, displayName: tricepsDisplayName),
      ];

  static WorkoutCategoryShell otherCategoryShell =
      WorkoutCategoryShell(id: 15, type: WorkoutCategoryType.other, displayName: otherDisplayName);
}
