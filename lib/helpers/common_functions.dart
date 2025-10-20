import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/calendar_view.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/drag_handle.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/forms/date_time_picker.dart';
import 'package:gymvision/widgets/forms/duration_picker.dart';
import 'package:gymvision/widgets/pages/workout/workout_view.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
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
}) async =>
    await showCloseableBottomSheet(context, CalendarView(events: events, onDateSelected: onDateSelected));

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
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

Future showFullScreenBottomSheet(BuildContext context, Widget child) async => await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.fromLTRB(
            10,
            10,
            10,
            MediaQuery.of(context).viewInsets.bottom, // for keyboard space
          ),
          child: Column(children: [
            const DragHandle(),
            Expanded(child: child),
          ]),
        ),
      ),
    );

Future addActiveWorkout(BuildContext context, {List<Category>? categories}) async {
  try {
    final activeWorkout = await WorkoutModel.getActiveWorkout();

    if ((activeWorkout != null)) {
      var continuingAdd = false;

      if (context.mounted) {
        await showCustomDialog(
          context,
          icon: Icons.directions_run_rounded,
          title: 'Ongoing Workout',
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

      if (!continuingAdd) return;
    }

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
      WorkoutView(
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
