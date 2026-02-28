import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_set.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_category_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/widgets/pages/workout/workout_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WorkoutHelper {
  static Future<bool> checkForAndFinishActiveWorkout(BuildContext context) async {
    try {
      final activeWorkout = await WorkoutModel.getActiveWorkout();
      if (activeWorkout == null) return true;

      var continuingAdd = false;
      if (context.mounted) {
        await DialogHelper.showCustomDialog(
          context,
          icon: Icons.directions_run_rounded,
          title: 'Active Workout',
          content: Text('Finish the active workout before creating another!'),
          customActions: [
            CupertinoDialogAction(
              child: Text(
                'Finish & Start New',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.pop(context);
                activeWorkout.endDate = DateTime.now();
                WorkoutModel.update(activeWorkout);
                continuingAdd = true;
              },
            )
          ],
        );
      }

      return continuingAdd;
    } catch (ex) {
      if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to finish Active Workout');
      return false;
    }
  }

  static Future<bool> copyTemplateToworkout({required int workoutId, required int templateId}) async {
    final template = await WorkoutTemplateModel.getTemplate(templateId);
    if (template == null) return false;
    return await _copyTemplateToWorkoutInner(workoutId: workoutId, template: template);
  }

  static Future<bool> _copyTemplateToWorkoutInner({required int workoutId, required WorkoutTemplate template}) async {
    try {
      final templateCategories = template.getCategories();
      if (templateCategories.isNotEmpty) {
        await WorkoutCategoryModel.setWorkoutCategories(workoutId, templateCategories);
      }

      final exercises = template.getWorkoutTemplateExercises();
      if (exercises.isEmpty) return true;

      for (final exercise in OrderingHelper.sortByOrder(exercises, template.exerciseOrder)) {
        final newWeId = await WorkoutExerciseModel.insert(WorkoutExercise(
          workoutId: workoutId,
          exerciseIdentifier: exercise.exerciseIdentifier,
          setOrder: '',
        ));

        final sets = exercise.getSets();
        if (sets.isNotEmpty) {
          for (final set in sets) {
            await WorkoutSetModel.insert(WorkoutSet(
              workoutExerciseId: newWeId,
              weight: set.weight,
              reps: set.reps,
              time: set.time,
              distance: set.distance,
              calsBurned: set.calsBurned,
            ));
          }
        }
      }

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future createActiveWorkoutFromTemplate(BuildContext context, {required int templateId}) async {
    try {
      if (!(await checkForAndFinishActiveWorkout(context))) return;

      final template = await WorkoutTemplateModel.getTemplate(templateId);
      if (template == null) {
        if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to find Template!');
        return;
      }

      final newWorkout = Workout(date: DateTime.now(), exerciseOrder: '');
      final newWorkoutId = await WorkoutModel.insert(newWorkout);

      final success = await _copyTemplateToWorkoutInner(workoutId: newWorkoutId, template: template);
      if (!success) {
        if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to copy Template to Workout!');
        return;
      }

      if (context.mounted) await openWorkoutView(context, newWorkoutId);
    } catch (ex) {
      if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to add Workout from Template!');
    }
  }

  static Future<int?> createTemplateFromWorkout(int workoutId) async {
    try {
      final workout = await WorkoutModel.getWorkout(workoutId, withCategories: true, withExercises: true);
      if (workout == null) return null;

      final newTemplate = WorkoutTemplate(
        name: 'Template from ${DateFormat(DateTimeHelper.dmyFormat).format(workout.date)}',
      );

      newTemplate.setCategories(workout.getCategories());
      final newTemplateId = await WorkoutTemplateModel.insert(newTemplate);

      for (final we in workout.getWorkoutExercises()) {
        final newWteId = await WorkoutTemplateModel.insertWorkoutTemplateExercise(WorkoutTemplateExercise(
          workoutTemplateId: newTemplateId,
          exerciseIdentifier: we.exerciseIdentifier,
          setOrder: '',
        ));

        for (final set in we.getSets()) {
          await WorkoutTemplateModel.insertWorkoutTemplateSet(WorkoutTemplateSet(
            workoutTemplateExerciseId: newWteId,
            weight: set.weight,
            reps: set.reps,
            time: set.time,
            distance: set.distance,
            calsBurned: set.calsBurned,
          ));
        }
      }

      return newTemplateId;
    } catch (ex) {
      return null;
    }
  }

  static Future createActiveWorkout(BuildContext context, {List<Category>? categories}) async {
    try {
      if (!(await checkForAndFinishActiveWorkout(context))) return;

      final newWorkoutId = await WorkoutModel.insert(Workout(date: DateTime.now(), exerciseOrder: ''));
      if (categories != null && categories.isNotEmpty) {
        await WorkoutCategoryModel.setWorkoutCategories(newWorkoutId, categories);
      }

      if (context.mounted) await openWorkoutView(context, newWorkoutId);
    } catch (ex) {
      if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to add workout!');
    }
  }

  static Future<void> openWorkoutView(
    BuildContext context,
    int workoutId, {
    bool autofocusNotes = false,
    int? focusedWorkoutExerciseId,
  }) async {
    final activeWorkoutProvider = context.read<ActiveWorkoutProvider>();
    final isActiveWorkout = await activeWorkoutProvider.isActiveWorkout(workoutId);
    if (!context.mounted) return;
    if (isActiveWorkout) activeWorkoutProvider.setOpen();

    try {
      await BottomSheetHelper.showFullScreenBottomSheet(
        context,
        closable: true,
        child: WorkoutView(
          workoutId: workoutId,
          isActiveWorkout: isActiveWorkout,
          autofocusNotes: autofocusNotes,
          focusedWorkoutExerciseId: focusedWorkoutExerciseId,
        ),
      );
    } finally {
      if (context.mounted && isActiveWorkout) activeWorkoutProvider.setClosed();
      activeWorkoutProvider.refreshActiveWorkout();
    }
  }
}
