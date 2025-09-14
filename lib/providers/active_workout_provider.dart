import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  bool _isActiveWorkoutBarOpen = false;
  Future<Workout?> _activeWorkoutFuture = WorkoutModel.getActiveWorkout();

  bool get isActiveWorkoutBarOpen => _isActiveWorkoutBarOpen;
  Future<Workout?> get activeWorkoutFuture => _activeWorkoutFuture;

  void openActiveWorkout(BuildContext context, {Workout? workout}) async {
    final globalContext = Provider.of<NavigationProvider>(context, listen: false).getGlobalContext();

    workout ??= await WorkoutModel.getActiveWorkout();
    if (workout == null || globalContext == null || !globalContext.mounted) return;

    openWorkoutView(globalContext, workout.id!);
    _isActiveWorkoutBarOpen = true;
  }

  void closeActiveWorkout() => _isActiveWorkoutBarOpen = false;

  void refreshActiveWorkout() {
    _activeWorkoutFuture = WorkoutModel.getActiveWorkout();
    notifyListeners();
  }
}
