import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutProvider extends ChangeNotifier {
  bool _activeWorkoutIsOpen = false;
  Future<Workout?> _activeWorkoutFuture = WorkoutModel.getActiveWorkout();

  bool get activeWorkoutIsOpen => _activeWorkoutIsOpen;
  Future<Workout?> get activeWorkoutFuture => _activeWorkoutFuture;

  void setOpen() => _activeWorkoutIsOpen = true;
  void setClosed() => _activeWorkoutIsOpen = false;

  void openActiveWorkout(BuildContext context) async {
    final globalContext = Provider.of<NavigationProvider>(context, listen: false).getGlobalContext();
    final activeWorkout = await WorkoutModel.getActiveWorkout();
    if (activeWorkout == null || globalContext == null || !globalContext.mounted) return;
    setOpen();
    openWorkoutView(globalContext, activeWorkout.id!);
  }

  Future<bool> isActiveWorkout(int workoutId) async => (await WorkoutModel.getActiveWorkout())?.id == workoutId;

  void refreshActiveWorkout() {
    _activeWorkoutFuture = WorkoutModel.getActiveWorkout();
    notifyListeners();
  }
}
