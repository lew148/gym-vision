import 'package:gymvision/classes/db/_database_object.dart';

class WorkoutExerciseOrdering extends DatabaseObject {
  final int workoutId;
  String? positions;

  WorkoutExerciseOrdering({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.workoutId,
    this.positions,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'workoutId': workoutId,
        'positions': positions,
      };

  void setPositions(List<int> workoutExerciseIds) => positions = workoutExerciseIds.map((i) => i.toString()).join(',');
  List<int> getPositions() => positions == null || positions == ''
      ? []
      : positions!.split(',').map((e) => int.tryParse(e)).whereType<int>().toList();

  void addExerciseToOrdering(int workoutExerciseId) {
    var positionsIntList = getPositions();
    if (positionsIntList.contains(workoutExerciseId)) return;
    positionsIntList.add(workoutExerciseId);
    setPositions(positionsIntList);
  }

  void removeExerciseFromOrdering(int workoutId, int workoutExerciseId) {
    var positionsIntList = getPositions();
    if (!positionsIntList.contains(workoutExerciseId)) return;
    positionsIntList.remove(workoutExerciseId);
    setPositions(positionsIntList);
  }

  void reorderExercises(int workoutId, int oldIndex, int newIndex) {
    var positionsIntList = getPositions();
    if (positionsIntList.isEmpty) return;
    var workoutExerciseId = positionsIntList[oldIndex];
    positionsIntList.removeAt(oldIndex);
    positionsIntList.insert(newIndex, workoutExerciseId);
    setPositions(positionsIntList);
  }
}
