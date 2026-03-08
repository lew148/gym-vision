import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/picker_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/helpers/functions/workout_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/workouts/summary/sharable_workout_summary.dart';
import 'package:gymvision/widgets/forms/templates/edit_workout_template_form.dart';
import 'package:provider/provider.dart';

class WorkoutOptionsMenu extends StatelessWidget {
  final Workout workout;
  final Function? onChange;
  final List<Button>? extraButtons;
  final bool fromWorkoutView;

  const WorkoutOptionsMenu({
    super.key,
    required this.workout,
    this.onChange,
    this.extraButtons,
    this.fromWorkoutView = false,
  });

  @override
  Widget build(BuildContext context) {
    void showEditTime(Workout workout) => PickerHelper.showDateTimePicker(
          context,
          initialDateTime: workout.date,
          CupertinoDatePickerMode.dateAndTime,
          (DateTime dt) async {
            try {
              workout.date = dt;
              await WorkoutModel.update(workout);
              if (context.mounted) Provider.of<ActiveWorkoutProvider>(context, listen: false).refreshActiveWorkout();
              if (onChange != null) onChange!();
            } catch (ex) {
              // do nothing
            }
          },
        );

    void showEditEndTime(Workout workout) => PickerHelper.showDateTimePicker(
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
      if (workout.isFinished()) ...[
        Button(
          onTap: () async {
            Navigator.pop(context);
            await BottomSheetHelper.showCloseableBottomSheet(context, SharableWorkoutSummary(workoutId: workout.id!));
          },
          icon: Icons.share_rounded,
          style: ButtonCustomStyle.mutedTextOnly(),
          text: 'Share / Summary',
        ),
        Button(
          onTap: () async {
            Navigator.pop(context);
            final newTemplateId = await WorkoutHelper.createTemplateFromWorkout(workout.id!);
            if (!context.mounted) return;

            if (newTemplateId == null) {
              ToastHelper.showFailureToast(context, message: 'Failed to create template!');
              return;
            }

            await BottomSheetHelper.showFullScreenBottomSheet(
              context,
              child: EditWorkoutTemplateForm(templateId: newTemplateId),
            );
          },
          icon: Icons.description_rounded,
          style: ButtonCustomStyle.mutedTextOnly(),
          text: 'Create Template from Workout',
        ),
      ],
      ...?extraButtons,
      Button(
        onTap: () {
          Navigator.pop(context);
          showEditTime(workout);
        },
        icon: Icons.access_time_rounded,
        style: ButtonCustomStyle.mutedTextOnly(),
        text: 'Change Start Date/Time',
      ),
      if (workout.isFinished())
        Button(
          onTap: () {
            Navigator.pop(context);
            showEditEndTime(workout);
          },
          icon: Icons.access_time_rounded,
          style: ButtonCustomStyle.mutedTextOnly(),
          text: 'Change End Time',
        ),
      Button.delete(
        onTap: () async {
          Navigator.pop(context);
          await DialogHelper.showDeleteConfirm(
            context,
            "workout",
            () async {
              final provider = Provider.of<ActiveWorkoutProvider>(context, listen: false);
              await WorkoutModel.delete(workout.id!);
              provider.refreshActiveWorkout();
              if (onChange != null) onChange!();
            },
          );

          if (context.mounted && await context.read<ActiveWorkoutProvider>().isActiveWorkout(workout.id!)) {
            if (context.mounted) await context.read<RestTimerProvider>().clearTimer();
          }

          if (context.mounted && fromWorkoutView) Navigator.pop(context);
        },
        text: 'Delete Workout',
      ),
    ]);
  }
}
