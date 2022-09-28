class WorkoutExercise {
  int? id;
  final int workoutId;
  final int exerciseId;
  int? sets;

  WorkoutExercise(
      {this.id, required this.workoutId, required this.exerciseId, this.sets});

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'sets': sets
      };
}
