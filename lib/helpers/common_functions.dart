import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/forms/date_time_picker.dart';
import 'package:gymvision/widgets/forms/duration_picker.dart';
import 'package:gymvision/widgets/pages/workout/workout_view.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<T> runSafe<T>(
  Function f, {
  required T fallback,
  bool logToSentry = false,
  String? sentryMessage,
  BuildContext? context,
  String? snackBarMessage,
}) async {
  try {
    return await f();
  } catch (ex, stack) {
    if (context != null && context.mounted) {
      showSnackBar(context, snackBarMessage ?? 'An error has occured.');
    }

    if (logToSentry || sentryMessage != null) {
      sentryMessage == null
          ? await Sentry.captureException(ex, stackTrace: stack)
          : await Sentry.captureMessage(sentryMessage);
    }
  }

  return fallback;
}

void showDeleteConfirm(
  BuildContext context,
  String objectName,
  Function onDelete,
  Function? reloadState, {
  bool popCaller = false,
}) {
  HapticFeedback.heavyImpact();
  showDialog(
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
            Navigator.pop(context);
            if (popCaller) Navigator.pop(context);

            try {
              await onDelete();
            } catch (ex) {
              if (!context.mounted) return;
              showSnackBar(context, 'Failed to delete $objectName: ${ex.toString()}');
            }

            if (reloadState != null) reloadState();
          },
        ),
      ],
    ),
  );
}

Future<bool> showConfirm(
  BuildContext context,
  String title,
  String content, {
  Function? onConfirm,
}) async {
  HapticFeedback.heavyImpact();
  var confirmed = false;
  await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
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
  BuildContext context,
  Widget title,
  Widget content, {
  List<CupertinoDialogAction>? actions,
}) async {
  HapticFeedback.heavyImpact();
  await showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions ??
          [
            CupertinoDialogAction(
              child: Text(
                'Done',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
    ),
  );
}

void showDateTimePicker(
  BuildContext context,
  CupertinoDatePickerMode mode,
  Function(DateTime) onChange, {
  DateTime? initialDateTime,
}) =>
    showCloseableBottomSheet(
      context,
      DateTimePicker(
        onChange: onChange,
        mode: mode,
        initialValue: initialDateTime,
      ),
    );

void showDurationPicker(
  BuildContext context,
  CupertinoTimerPickerMode mode,
  Function(Duration) onChange, {
  Duration? initialDuration,
  bool isTimer = false,
}) =>
    showCloseableBottomSheet(
      context,
      DurationPicker(
        onChange: onChange,
        mode: mode,
        initialValue: initialDuration,
        isTimer: isTimer,
      ),
    );

Future showCloseableBottomSheet(BuildContext context, Widget child, {String? title}) => showModalBottomSheet(
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
              SizedBox(
                width: 100,
                child: Divider(
                  color: Theme.of(context).colorScheme.shadow,
                  thickness: 4,
                  radius: const BorderRadius.all(Radius.circular(25)),
                ),
              ),
              if (title != null) ...[
                Header(title: title),
                const CustomDivider(),
              ] else
                const Padding(padding: EdgeInsetsGeometry.all(10)),
              child,
            ]),
          ),
        ],
      ),
    );

Future showFullScreenBottomSheet(
  BuildContext context,
  Widget child, {
  List<Widget> actions = const [],
  Function? onClose,
}) =>
    showModalBottomSheet(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (actions.isNotEmpty) Row(children: actions),
                ],
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    ).then((x) {
      if (onClose != null) onClose();
    });

Future onAddWorkoutTap(
  BuildContext context,
  Function reloadState, {
  DateTime? date,
  List<Category>? categories,
}) async {
  try {
    var now = DateTime.now();

    if (date != null) {
      date = DateTime(date.year, date.month, date.day, now.hour, now.minute, now.second, now.millisecond);
    }

    final newWorkoutId = await WorkoutModel.insert(Workout(date: date ?? now, exerciseOrder: ''));
    if (categories != null && categories.isNotEmpty) {
      await WorkoutCategoryModel.setWorkoutCategories(newWorkoutId, categories);
    }

    if (!context.mounted) return;
    openWorkoutView(context, newWorkoutId, reloadState: reloadState);
  } catch (ex) {
    showSnackBar(context, 'Failed to add workout');
  }
}

Future deleteWorkout(BuildContext context, int workoutId) async {
  final provider = Provider.of<ActiveWorkoutProvider>(context, listen: false);
  await WorkoutModel.delete(workoutId);
  provider.closeActiveWorkout();
  provider.refreshActiveWorkout();
}

void openWorkoutView(
  BuildContext context,
  int workoutId, {
  Function? reloadState,
  bool autofocusNotes = false,
  List<int>? droppedWes,
}) {
  final provider = Provider.of<ActiveWorkoutProvider>(context, listen: false);
  showFullScreenBottomSheet(
    context,
    WorkoutView(
      workoutId: workoutId,
      reloadParent: reloadState,
      autofocusNotes: autofocusNotes,
      droppedWes: droppedWes,
    ),
    onClose: () {
      provider.closeActiveWorkout(); // always close active workout
      provider.refreshActiveWorkout();
      if (reloadState != null) reloadState();
    },
  );
}

void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

void setRestTimer(BuildContext context, Duration duration) =>
    Provider.of<RestTimerProvider>(context, listen: false).setTimer(context: context, duration: duration);
