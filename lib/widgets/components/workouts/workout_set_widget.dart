import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
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
            showSnackBar(context, 'Cannot complete sets in the future');
            return false;
          }

          if (!isCardio && (set.reps == null || set.reps == 0)) {
            showSnackBar(context, 'Sets must have reps');
            return false;
          }
        }

        set.done = done;
        final success = await WorkoutSetModel.update(set);
        if (!success) throw Exception();

        final settings = await UserSettingsModel.getUserSettings();
        if (done && settings.intraSetRestTimer != null && context.mounted) {
          setRestTimer(context, settings.intraSetRestTimer!);
        }

        reloadParent();
        return true;
      } catch (ex) {
        return false;
      }
    }

    Widget getCheckAndIndex(int flex) => Expanded(
          flex: flex,
          child: Row(
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
              )
            ],
          ),
        );

    List<Widget> getCardioSetContents() => [
          getCheckAndIndex(2),
          Expanded(flex: 4, child: TextWithIcon.duration(set.time, alignment: MainAxisAlignment.center)),
          Expanded(flex: 4, child: TextWithIcon.distance(set.distance, alignment: MainAxisAlignment.center)),
          Expanded(flex: 4, child: TextWithIcon.caloriesBurned(set.calsBurned, alignment: MainAxisAlignment.center)),
        ];

    List<Widget> getWeightedSetContents() => [
          getCheckAndIndex(4),
          Expanded(flex: 4, child: TextWithIcon.weight(set.weight, alignment: MainAxisAlignment.start)),
          Expanded(flex: 4, child: TextWithIcon.reps(set.reps, alignment: MainAxisAlignment.start)),
        ];

    Widget getSetWidgetInner() => Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: isCardio ? getCardioSetContents() : getWeightedSetContents(),
          ),
        );

    void onEditWorkoutSetTap() async => await showCloseableBottomSheet(
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
        showSnackBar(context, 'Failed add set to workout: ${ex.toString()}');
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
                      if (context.mounted) showSnackBar(context, 'Failed to remove set from workout');
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
