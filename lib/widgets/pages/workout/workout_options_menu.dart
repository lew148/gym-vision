import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:provider/provider.dart';

class WorkoutOptionsMenu extends StatelessWidget {
  final Workout workout;
  final Function? onChange;
  final List<Button>? extraButtons;
  final bool popCallerOnDelete;

  const WorkoutOptionsMenu({
    super.key,
    required this.workout,
    this.onChange,
    this.extraButtons,
    this.popCallerOnDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    void showEditTime(Workout workout) => showDateTimePicker(
          context,
          initialDateTime: workout.date,
          CupertinoDatePickerMode.time,
          (DateTime dt) async {
            try {
              workout.date = DateTime(
                workout.date.year,
                workout.date.month,
                workout.date.day,
                dt.hour,
                dt.minute,
                dt.second,
              );
              await WorkoutModel.update(workout);
              if (onChange != null) onChange!();
            } catch (ex) {
              // do nothing
            }
          },
        );

    void showEditEndTime(Workout workout) => showDateTimePicker(
          context,
          initialDateTime: workout.endDate,
          CupertinoDatePickerMode.dateAndTime,
          (DateTime dt) async {
            try {
              workout.endDate = dt;
              await WorkoutModel.update(workout);
              if (onChange != null) onChange!();
            } catch (ex) {
              // do nothing
            }
          },
        );

    return OptionsMenu(buttons: [
      //   Button
      //     onTap: () async {
      //       Navigator.pop(context);

      //       try {
      //         final exportString = await WorkoutModel.getWorkoutExportString(workout.id!);
      //         if (exportString == null) throw Exception();
      //         await Clipboard.setData(ClipboardData(text: exportString));
      //         if (mounted) showSnackBar(context, 'Workout copied to clipboard!');
      //       } catch (ex) {
      //         if (mounted) showSnackBar(context, 'Failed to export workout.');
      //       }
      //     },
      //     icon: Icons.share_rounded,
      //     text: 'Export Workout',
      //   ),
      ...?extraButtons,
      Button(
        onTap: () {
          Navigator.pop(context);
          showEditTime(workout);
        },
        icon: Icons.access_time_rounded,
        style: ButtonCustomStyle.primaryIconOnly(),
        text: 'Change Start Time',
      ),
      if (workout.isFinished())
        Button(
          onTap: () {
            Navigator.pop(context);
            showEditEndTime(workout);
          },
          icon: Icons.access_time_rounded,
          style: ButtonCustomStyle.primaryIconOnly(),
          text: 'Change End Time',
        ),
      Button.delete(
        onTap: () {
          Navigator.pop(context);
          showDeleteConfirm(
            context,
            "workout",
            () async {
              final provider = Provider.of<ActiveWorkoutProvider>(context, listen: false);
              await WorkoutModel.delete(workout.id!);
              provider.refreshActiveWorkout();
              if (onChange != null) onChange!();
            },
            null,
            popCaller: popCallerOnDelete,
          );
        },
        text: 'Delete Workout',
      ),
    ]);
  }
}
