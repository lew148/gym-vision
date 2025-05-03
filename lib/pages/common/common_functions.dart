import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';

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
      builder: (context) => AlertDialog(
        title: Text("Remove $objectName?"),
        content: Text("Are you sure you would like to remove this $objectName?"),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Yes",
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
                    .showSnackBar(SnackBar(content: Text('Failed to remove $objectName: ${ex.toString()}')));
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

  static void onAddWorkoutTap(BuildContext context, Function reloadState, {DateTime? date}) async {
    try {
      var now = DateTime.now();

      if (date != null) {
        date = DateTime(date.year, date.month, date.day, now.hour, now.minute);
      }

      final newWorkoutId = await WorkoutModel.insertWorkout(Workout(date: date ?? now));
      if (!context.mounted) return;

      Navigator.of(context)
          .push(
              MaterialPageRoute(builder: (context) => WorkoutView(workoutId: newWorkoutId, reloadParent: reloadState)))
          .then((value) => reloadState());
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add workout')));
    }
  }
}
