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

class CategoryShellHelper {
  static Map<int, List<WorkoutCategoryShell>> getCategoryShellsMap() => {
        0: getFunctionaityCategoryShells(),
        1: getSplitCategoryShells(),
        2: getMuscleGroupCategoryShells(),
        // 3: [otherCategoryShell],
      };

  static List<WorkoutCategoryShell> getCategoryShells() {
    List<WorkoutCategoryShell> list = [];
    list.addAll(getFunctionaityCategoryShells());
    list.addAll(getSplitCategoryShells());
    list.addAll(getMuscleGroupCategoryShells());
    list.add(otherCategoryShell);
    return list;
  }

  static int getMapIndexOfShell(int shellId) {
    var map = getCategoryShellsMap();
    map.removeWhere((k, v) => !v.any((wcs) => wcs.id == shellId));
    return map.keys.first;
  }

  static List<WorkoutCategoryShell> getCategoryShellsWithIds(List<int> shellIds) =>
      getCategoryShells().where((s) => shellIds.contains(s.id)).toList();

  static List<WorkoutCategoryShell> getFunctionaityCategoryShells() => [
        WorkoutCategoryShell(id: 1, type: WorkoutCategoryType.cardio, displayName: cardioDisplayName),
        WorkoutCategoryShell(id: 2, type: WorkoutCategoryType.stretch, displayName: stretchDisplayName),
      ];

  static List<WorkoutCategoryShell> getSessionTypeCategoryShells() => [
        WorkoutCategoryShell(id: 3, type: WorkoutCategoryType.Class, displayName: classDisplayName),
      ];

  static List<WorkoutCategoryShell> getSplitCategoryShells() => [
        WorkoutCategoryShell(id: 4, type: WorkoutCategoryType.split, displayName: pushDisplayName),
        WorkoutCategoryShell(id: 5, type: WorkoutCategoryType.split, displayName: pullDisplayName),
        WorkoutCategoryShell(id: 6, type: WorkoutCategoryType.split, displayName: legsDisplayName),
      ];

  static List<WorkoutCategoryShell> getMuscleGroupCategoryShells() => [
        WorkoutCategoryShell(id: 7, type: WorkoutCategoryType.muscleGroup, displayName: backDisplayName),
        WorkoutCategoryShell(id: 8, type: WorkoutCategoryType.muscleGroup, displayName: bicepsDisplayName),
        WorkoutCategoryShell(id: 9, type: WorkoutCategoryType.muscleGroup, displayName: chestDisplayName),
        WorkoutCategoryShell(id: 10, type: WorkoutCategoryType.muscleGroup, displayName: coreDisplayName),
        WorkoutCategoryShell(id: 11, type: WorkoutCategoryType.muscleGroup, displayName: forearmsDisplayName),
        WorkoutCategoryShell(
            id: 12, type: WorkoutCategoryType.muscleGroup, displayName: hamstringsAndGlutesDisplayName),
        WorkoutCategoryShell(id: 13, type: WorkoutCategoryType.muscleGroup, displayName: quadsAndCalvesDisplayName),
        WorkoutCategoryShell(id: 14, type: WorkoutCategoryType.muscleGroup, displayName: shouldersDisplayName),
        WorkoutCategoryShell(id: 15, type: WorkoutCategoryType.muscleGroup, displayName: tricepsDisplayName),
      ];

  static WorkoutCategoryShell otherCategoryShell =
      WorkoutCategoryShell(id: 16, type: WorkoutCategoryType.other, displayName: otherDisplayName);
}
