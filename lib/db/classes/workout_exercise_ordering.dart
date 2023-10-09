class WorkoutExerciseOrdering {
  int? id;
  final int workoutId;
  String? positions;

  WorkoutExerciseOrdering({
    this.id,
    required this.workoutId,
    this.positions,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'positions': positions,
      };

  void setPositions(List<int> exerciseIds) => positions = exerciseIds.map((i) => i.toString()).join(',');

  List<int> getPositions() {
    if (positions == null || positions == '') return [];
    return positions!.split(',').map((e) => int.tryParse(e)).whereType<int>().toList();
  }
}
