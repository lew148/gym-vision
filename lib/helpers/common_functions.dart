import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_category_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/calendar_view.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/drag_handle.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/forms/fields/date_time_picker.dart';
import 'package:gymvision/widgets/forms/fields/duration_picker.dart';
import 'package:gymvision/widgets/pages/workout/workout_view.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:provider/provider.dart';

Future showDeleteConfirm(BuildContext context, String objectName, Function onDelete) async {
  HapticFeedback.heavyImpact();
  await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text("Delete $objectName?"),
      content: Text("Are you sure you would like to delete this $objectName?"),
      actions: [
        CupertinoDialogAction(
          child: const Text("Keep"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onPressed: () async {
            try {
              await onDelete();
            } catch (ex) {
              if (!context.mounted) return;
              showSnackBar(context, 'Failed to delete $objectName: ${ex.toString()}');
            }

            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  Function? onConfirm,
  String? content,
}) async {
  HapticFeedback.heavyImpact();
  var confirmed = false;
  await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: content == null ? null : Text(content),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('Confirm',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.pop(context);
            confirmed = true;
            if (onConfirm != null) onConfirm();
          },
        ),
      ],
    ),
  );

  return confirmed;
}

Future showCustomDialog(
  BuildContext context, {
  required String title,
  IconData? icon,
  String? content,
  List<CupertinoDialogAction>? customActions,
  bool includeOK = true,
}) async {
  HapticFeedback.heavyImpact();
  await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
        title: icon == null
            ? Text(title)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                  Text(title),
                ],
              ),
        content: (content == null ? null : Text(content)),
        actions: [
          if (customActions != null) ...customActions,
          if (includeOK)
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
        ]),
  );
}

Future showCalendarView(
  BuildContext context, {
  required Map<DateTime, List<CalendarViewEvent>> events,
  void Function(DateTime? selectedDay)? onDateSelected,
  DateTime? selectedDate,
}) async =>
    await showCloseableBottomSheet(
      context,
      CalendarView(
        events: events,
        onDateSelected: onDateSelected,
        selectedDate: selectedDate,
      ),
    );

Future showDateTimePicker(
  BuildContext context,
  CupertinoDatePickerMode mode,
  Function(DateTime) onChange, {
  DateTime? initialDateTime,
}) async =>
    await showCloseableBottomSheet(
      context,
      DateTimePicker(onChange: onChange, mode: mode, initialValue: initialDateTime),
    );

Future showDurationPicker(
  BuildContext context,
  CupertinoTimerPickerMode mode, {
  Function(Duration)? onChange,
  Function(Duration)? onSubmit,
  Duration? initialDuration,
  bool isTimer = false,
}) async =>
    await showCloseableBottomSheet(
      context,
      DurationPicker(
        onChange: onChange,
        onSubmit: onSubmit,
        mode: mode,
        initialValue: initialDuration,
        isTimer: isTimer,
      ),
    );

Future showCloseableBottomSheet(BuildContext context, Widget child, {String? title}) async =>
    await showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(largeBorderRadius)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              5,
              20,
              MediaQuery.of(context).viewInsets.bottom > 0
                  ? 10 + MediaQuery.of(context).viewInsets.bottom
                  : 30, // add viewInsets.bottom for keyboard space
            ),
            child: Column(children: [
              const DragHandle(),
              if (title != null) ...[
                Header(title: title),
                const CustomDivider(),
              ],
              child,
            ]),
          ),
        ],
      ),
    );

Future showFullScreenBottomSheet(BuildContext context, {required Widget child, bool closable = false}) async =>
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: closable,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(largeBorderRadius)),
        ),
        padding: EdgeInsets.fromLTRB(
          10,
          10,
          10,
          MediaQuery.of(context).viewInsets.bottom, // for keyboard space
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Column(children: [
            if (closable) const DragHandle(),
            Expanded(child: child),
          ]),
        ),
      ),
    );

Future<bool> checkForAndFinishActiveWorkout(BuildContext context) async {
  try {
    final activeWorkout = await WorkoutModel.getActiveWorkout();
    if (activeWorkout == null) return true;

    var continuingAdd = false;
    if (context.mounted) {
      await showCustomDialog(
        context,
        icon: Icons.directions_run_rounded,
        title: 'Active Workout',
        content: 'Finish the active workout before creating another!',
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
    if (context.mounted) showSnackBar(context, 'Failed to finish Active Workout');
    return false;
  }
}

Future<bool> copyTemplateToworkout({required int workoutId, required int templateId}) async {
  final template = await WorkoutTemplateModel.getTemplate(templateId);
  if (template == null) return false;
  return await _copyTemplateToWorkoutInner(workoutId: workoutId, template: template);
}

Future<bool> _copyTemplateToWorkoutInner({required int workoutId, required WorkoutTemplate template}) async {
  try {
    final templateCategories = template.getCategories();
    if (templateCategories.isNotEmpty) {
      await WorkoutCategoryModel.setWorkoutCategories(workoutId, templateCategories);
    }

    final exercises = template.getWorkoutTemplateExercises();
    if (exercises.isNotEmpty) {
      for (final exercise in exercises) {
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
    }

    return true;
  } catch (ex) {
    return false;
  }
}

Future createActiveWorkoutFromTemplate(BuildContext context, {required int templateId}) async {
  try {
    if (!(await checkForAndFinishActiveWorkout(context))) return;

    final template = await WorkoutTemplateModel.getTemplate(templateId);
    if (template == null) {
      if (context.mounted) showSnackBar(context, 'Could\'nt find Template!');
      return;
    }

    final newWorkout = Workout(date: DateTime.now(), exerciseOrder: '');
    final newWorkoutId = await WorkoutModel.insert(newWorkout);

    final success = await _copyTemplateToWorkoutInner(workoutId: newWorkoutId, template: template);
    if (!success) {
      if (context.mounted) showSnackBar(context, 'Could\'nt copy Template to Workout!');
      return;
    }

    if (context.mounted) await openWorkoutView(context, newWorkoutId);
  } catch (ex) {
    if (context.mounted) showSnackBar(context, 'Failed to add Workout from Template');
  }
}

Future createActiveWorkout(BuildContext context, {List<Category>? categories}) async {
  try {
    if (!(await checkForAndFinishActiveWorkout(context))) return;

    final newWorkoutId = await WorkoutModel.insert(Workout(date: DateTime.now(), exerciseOrder: ''));
    if (categories != null && categories.isNotEmpty) {
      await WorkoutCategoryModel.setWorkoutCategories(newWorkoutId, categories);
    }

    if (context.mounted) await openWorkoutView(context, newWorkoutId);
  } catch (ex) {
    if (context.mounted) showSnackBar(context, 'Failed to add workout');
  }
}

Future<void> openWorkoutView(
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
    await showFullScreenBottomSheet(
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

void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

void showSnackBar(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

void setRestTimer(BuildContext context, Duration duration) =>
    Provider.of<RestTimerProvider>(context, listen: false).setTimer(context: context, duration: duration);
