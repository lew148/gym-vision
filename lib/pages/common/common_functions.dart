import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/date_time_picker.dart';
import 'package:gymvision/pages/forms/duration_picker.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/static_data/enums.dart';
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
  String content,
) async {
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
    showCustomBottomSheet(
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
    showCustomBottomSheet(
      context,
      DurationPicker(
        onChange: onChange,
        mode: mode,
        initialValue: initialDuration,
        isTimer: isTimer,
      ),
    );

Future showCustomBottomSheet(BuildContext context, Widget child) => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );

Future showOptionsMenu(BuildContext context, List<ButtonDetails> list, {String? menuName}) =>
    showCustomBottomSheet(context, CommonUI.getModalMenu(context, list, modalName: menuName));

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

    final newWorkoutId = await WorkoutModel.insertWorkout(Workout(date: date ?? now));
    if (categories != null && categories.isNotEmpty) {
      await WorkoutCategoryModel.setWorkoutCategories(newWorkoutId, categories);
    }

    if (!context.mounted) return;
    openWorkoutView(context, newWorkoutId, reloadState: reloadState);
  } catch (ex) {
    showSnackBar(context, 'Failed to add workout');
  }
}

void openWorkoutView(BuildContext context, int workoutId, {Function? reloadState}) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WorkoutView(workoutId: workoutId, reloadParent: reloadState)))
        .then((value) {
      if (reloadState != null) reloadState();
    });

void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
