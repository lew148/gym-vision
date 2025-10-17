import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/static_data/enums.dart';

class WorkoutProvider extends ChangeNotifier {
  Workout? _workout;
  bool _loading = false;
  final List<int> _droppedWorkoutExerciseIds = [];

  Workout? get workout => _workout;
  bool get isLoading => _loading;
  List<int> get droppedWorkoutExerciseIds => _droppedWorkoutExerciseIds;

  Future<void> loadWorkout(int workoutId, {int? focusedWorkoutExerciseId}) async {
    _loading = true;
    notifyListeners();

    _workout = await WorkoutModel.getWorkout(workoutId, withCategories: true, withExercises: true);
    if (focusedWorkoutExerciseId != null) _droppedWorkoutExerciseIds.add(focusedWorkoutExerciseId);
    _loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    if (_workout == null) return;
    await loadWorkout(_workout!.id!);
  }

  Future<void> updateCategories(List<Category> newCategories) async {
    if (_workout == null) return;
    await WorkoutCategoryModel.setWorkoutCategories(_workout!.id!, newCategories);
    await reload();
  }

  void toggleDroppedExercise(int weId) {
    if (_droppedWorkoutExerciseIds.contains(weId)) {
      _droppedWorkoutExerciseIds.remove(weId);
    } else {
      _droppedWorkoutExerciseIds.add(weId);
    }
  }
}
