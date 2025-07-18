import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/static_data/enums.dart';

class CommonFunctions {
  static void showDeleteConfirm(
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
        // backgroundColor: Theme.of(context).cardColor,
        actions: [
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              if (popCaller) Navigator.pop(context);

              try {
                await onDelete();
              } catch (ex) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Failed to delete $objectName: ${ex.toString()}')));
              }

              if (reloadState != null) reloadState();
            },
          ),
        ],
      ),
    );
  }

  static Future showBottomSheet(BuildContext context, Widget child) => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      );

  static Future showOptionsMenu(BuildContext context, List<ButtonDetails> list, {String? menuName}) =>
      showBottomSheet(context, CommonUI.getModalMenu(context, list, modalName: menuName));

  static Future onAddWorkoutTap(
    BuildContext context,
    Function reloadState, {
    DateTime? date,
    List<Category>? categories,
  }) async {
    try {
      var now = DateTime.now();

      if (date != null) {
        date = DateTime(date.year, date.month, date.day, now.hour, now.minute);
      }

      final newWorkoutId = await WorkoutModel.insertWorkout(Workout(date: date ?? now));
      if (categories != null && categories.isNotEmpty) {
        await WorkoutCategoryModel.setWorkoutCategories(newWorkoutId, categories);
      }

      if (!context.mounted) return;

      Navigator.of(context)
          .push(
              MaterialPageRoute(builder: (context) => WorkoutView(workoutId: newWorkoutId, reloadParent: reloadState)))
          .then((value) => reloadState());
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add workout')));
    }
  }

  static void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
}
