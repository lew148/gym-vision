class WorkoutCategory {
  int? id;
  final int workoutId;
  final int categoryId;

  WorkoutCategory({this.id, required this.workoutId, required this.categoryId});

  Map<String, dynamic> toMap() =>
      {'id': id, 'workoutId': workoutId, 'categoryId': categoryId};
}
