import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/confetti_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/workouts/set_info_widget.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';
import 'package:gymvision/widgets/forms/workout_set_form.dart';

class WorkoutSetWidget extends StatelessWidget {
  final WorkoutSet set;
  final Function reloadParent;
  final bool isDisplay, isCardio, isInFuture;
  final String exerciseIdentifier;
  final int workoutId, setNumber;

  const WorkoutSetWidget({
    super.key,
    required this.set,
    required this.reloadParent,
    required this.isDisplay,
    required this.isCardio,
    required this.isInFuture,
    required this.exerciseIdentifier,
    required this.workoutId,
    required this.setNumber,
  });

  @override
  Widget build(BuildContext context) {
    Future<bool> onSetDoneTap(bool done) async {
      try {
        HapticFeedback.lightImpact();

        if (done) {
          if (isInFuture) {
            AppHelper.showSnackBar(context, 'Cannot complete sets in the future');
            return false;
          }

          if (!isCardio && (set.reps == null || set.reps == 0)) {
            AppHelper.showSnackBar(context, 'Sets must have reps');
            return false;
          }
        }

        final max = await WorkoutSetModel.getPR(exerciseIdentifier);

        set.done = done;
        final success = await WorkoutSetModel.update(set);
        if (!success) throw Exception();

        if (context.mounted && done) {
          if (max != null && set.isGreaterThan(max)) {
            if (context.mounted) ConfettiHelper.bothSidesInward(context);
          }

          final settings = await UserSettingsModel.getUserSettings();
          if (context.mounted && settings.intraSetRestTimer != null) {
            AppHelper.setRestTimer(context, settings.intraSetRestTimer!);
          }
        }

        reloadParent();
        return true;
      } catch (ex) {
        return false;
      }
    }

    Widget getCheckAndIndex() => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomCheckbox(
              value: set.done,
              onChangeAsync: isDisplay ? null : (value) => onSetDoneTap(value),
            ),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Text(
              setNumber.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        );

    SizedBox endPadding = const SizedBox(width: 15);

    List<Widget> getCardioSetContents() => [
          getCheckAndIndex(),
          Expanded(child: SetInfoWidget(info: set.info)),
          Expanded(child: StatDisplay.duration(set.time, useIcon: false, alignment: MainAxisAlignment.end)),
          endPadding,
          Expanded(child: StatDisplay.distance(set.distance, useIcon: false, alignment: MainAxisAlignment.end)),
          endPadding,
          Expanded(child: StatDisplay.caloriesBurned(set.calsBurned, useIcon: false, alignment: MainAxisAlignment.end)),
          endPadding,
        ];

    List<Widget> getWeightedSetContents() => [
          getCheckAndIndex(),
          Expanded(child: SetInfoWidget(info: set.info)),
          Expanded(child: StatDisplay.weight(set.weight, useIcon: false, alignment: MainAxisAlignment.end)),
          const SizedBox(width: 60),
          Expanded(child: StatDisplay.reps(set.reps, useIcon: false, alignment: MainAxisAlignment.end)),
          endPadding,
        ];

    Widget getSetWidgetInner() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(children: isCardio ? getCardioSetContents() : getWeightedSetContents()),
        );

    void onEditWorkoutSetTap() async => await BottomSheetHelper.showCloseableBottomSheet(
          context,
          WorkoutSetForm(
            exerciseIdentifier: exerciseIdentifier,
            workoutId: workoutId,
            onSuccess: reloadParent,
            workoutSet: set,
          ),
        );

    void onCopySetButtonTap() async {
      try {
        HapticFeedback.lightImpact();
        await WorkoutSetModel.insert(
          WorkoutSet(
            workoutExerciseId: set.workoutExerciseId,
            weight: set.weight,
            time: set.time,
            distance: set.distance,
            calsBurned: set.calsBurned,
            reps: set.reps,
            done: false,
          ),
        );
      } catch (ex) {
        if (!context.mounted) return;
        AppHelper.showSnackBar(context, 'Failed add set to workout: ${ex.toString()}');
      }

      reloadParent();
    }

    return isDisplay
        ? getSetWidgetInner()
        : InkWell(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
            enableFeedback: false,
            onLongPress: () => OptionsMenu.showOptionsMenu(
              context,
              buttons: [
                Button(
                  text: 'Copy Set',
                  icon: Icons.content_copy_rounded,
                  style: ButtonCustomStyle.primaryIconOnly(),
                  onTap: () => onCopySetButtonTap(),
                ),
                Button(
                  text: 'Edit Set',
                  icon: Icons.edit_rounded,
                  style: ButtonCustomStyle.primaryIconOnly(),
                  onTap: () {
                    Navigator.pop(context);
                    onEditWorkoutSetTap();
                  },
                ),
                Button(
                  text: 'Delete Set',
                  icon: Icons.delete_rounded,
                  style: ButtonCustomStyle.redIconOnly(),
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      await WorkoutSetModel.delete(set.id!);
                    } catch (ex) {
                      if (context.mounted) AppHelper.showSnackBar(context, 'Failed to remove set from workout');
                    }

                    reloadParent();
                  },
                ),
              ],
            ),
            onTap: onEditWorkoutSetTap,
            child: getSetWidgetInner(),
          );
  }
}
