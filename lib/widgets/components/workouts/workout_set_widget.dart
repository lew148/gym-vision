import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/confetti_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/providers/workout_stats_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/workouts/set_info_widget.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';
import 'package:gymvision/widgets/forms/workout_set_form.dart';
import 'package:provider/provider.dart';

class WorkoutSetWidget extends StatelessWidget {
  final WorkoutSet set;
  final Function reloadParent;
  final bool isDisplay, isInFuture;
  final int workoutId, setNumber;
  final Exercise exercise;

  const WorkoutSetWidget({
    super.key,
    required this.set,
    required this.reloadParent,
    required this.isDisplay,
    required this.isInFuture,
    required this.workoutId,
    required this.setNumber,
    required this.exercise,
  });

  static const int flex = 6;

  @override
  Widget build(BuildContext context) {
    final bool showHeaders = setNumber == 1;

    Future<bool> onSetDoneTap(bool done) async {
      try {
        HapticFeedback.lightImpact();

        if (done) {
          if (isInFuture) {
            ToastHelper.showDisallowedToast(context, message: 'Cannot complete sets in the future!');
            return false;
          }

          if (exercise.trackingMetrics.contains(TrackingMetric.reps) && (set.reps == null || set.reps == 0)) {
            ToastHelper.showDisallowedToast(context, message: 'Sets must have reps to be completed!');
            return false;
          }
        }

        final max = await WorkoutSetModel.getPR(exercise.identifier);

        set.done = done;
        final success = await WorkoutSetModel.update(set);
        if (!success) throw Exception();

        if (context.mounted && done) {
          if (max != null && set.isGreaterThan(max)) ConfettiHelper.bothSidesInward(context);

          final settings = await UserSettingsModel.getUserSettings();
          if (context.mounted && settings.intraSetRestTimer != null) {
            AppHelper.setRestTimer(context, settings.intraSetRestTimer!);
          }
        }

        if (context.mounted) context.read<WorkoutStatsProvider>().reload();
        reloadParent();
        return true;
      } catch (ex) {
        return false;
      }
    }

    Widget getContentsFromTrackingMetric(TrackingMetric tm) {
      switch (tm) {
        case TrackingMetric.weight:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.weight(
                set.weight,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
        case TrackingMetric.addedWeight:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.weight(
                set.addedWeight,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
        case TrackingMetric.assistedWeight:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.weight(
                set.assistedWeight,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
        case TrackingMetric.reps:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.reps(
                set.reps,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
        case TrackingMetric.time:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.duration(
                set.time,
                useIcon: false,
                alignment: MainAxisAlignment.end,
              ),
            ]),
          );
        case TrackingMetric.distance:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.distance(
                set.distance,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
        case TrackingMetric.calsBurned:
          return Expanded(
            flex: flex,
            child: Column(children: [
              StatDisplay.caloriesBurned(
                set.calsBurned,
                useIcon: false,
                alignment: MainAxisAlignment.end,
                showUnits: false,
              ),
            ]),
          );
      }
    }

    String getHeaderLabelForMetric(TrackingMetric tm) {
      switch (tm) {
        case TrackingMetric.weight:
          return 'kg';
        case TrackingMetric.addedWeight:
          return '+kg';
        case TrackingMetric.assistedWeight:
          return '-kg';
        case TrackingMetric.reps:
          return 'reps';
        case TrackingMetric.time:
          return 'h:m:s';
        case TrackingMetric.distance:
          return 'km';
        case TrackingMetric.calsBurned:
          return 'kcal';
      }
    }

    IconData getHeaderIconForMetric(TrackingMetric tm) {
      switch (tm) {
        case TrackingMetric.weight:
        case TrackingMetric.addedWeight:
        case TrackingMetric.assistedWeight:
          return Icons.fitness_center_rounded;
        case TrackingMetric.reps:
          return Icons.repeat_rounded;
        case TrackingMetric.time:
          return Icons.timer_rounded;
        case TrackingMetric.distance:
          return Icons.timeline_rounded;
        case TrackingMetric.calsBurned:
          return Icons.local_fire_department_rounded;
      }
    }

    Widget getCheckboxAndInfoBox({bool header = false}) => SizedBox(
          width: 100,
          child: header
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomCheckbox(
                      value: set.done,
                      onChangeAsync: isDisplay ? null : (value) => onSetDoneTap(value),
                    ),
                    SizedBox(width: 50, child: SetInfoWidget(info: set.info)),
                  ],
                ),
        );

    Widget getHeaderRow(List<TrackingMetric> metrics) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getCheckboxAndInfoBox(header: true),
            ...metrics.map(
              (tm) => Expanded(
                flex: flex,
                child: StatDisplay(
                  text: getHeaderLabelForMetric(tm),
                  icon: getHeaderIconForMetric(tm),
                  alignment: MainAxisAlignment.end,
                  muted: true,
                ),
              ),
            ),
          ],
        );

    Widget getDataRow(List<TrackingMetric> metrics) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getCheckboxAndInfoBox(),
            ...metrics.map((tm) => getContentsFromTrackingMetric(tm)),
          ],
        );

    Widget getSetWidgetInner() {
      final orderedMetrics = exercise.getOrderedTrackingMetrics();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(children: [
          if (showHeaders) ...[
            getHeaderRow(orderedMetrics),
            CustomDivider(shadow: true),
          ],
          getDataRow(orderedMetrics),
        ]),
      );
    }

    void onEditWorkoutSetTap() async => await BottomSheetHelper.showCloseableBottomSheet(
          context,
          WorkoutSetForm(
            exerciseIdentifier: exercise.identifier,
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
            addedWeight: set.addedWeight,
            assistedWeight: set.assistedWeight,
            reps: set.reps,
            done: false,
          ),
        );
      } catch (ex) {
        if (!context.mounted) return;
        ToastHelper.showFailureToast(context, message: 'Failed to add set to workout!');
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
                  style: ButtonCustomStyle.mutedTextOnly(),
                  onTap: () => onCopySetButtonTap(),
                ),
                Button(
                  text: 'Edit Set',
                  icon: Icons.edit_rounded,
                  style: ButtonCustomStyle.mutedTextOnly(),
                  onTap: () {
                    Navigator.pop(context);
                    onEditWorkoutSetTap();
                  },
                ),
                Button(
                  text: 'Delete Set',
                  icon: Icons.delete_rounded,
                  style: ButtonCustomStyle.redIconMutedText(),
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      await WorkoutSetModel.delete(set.id!);
                    } catch (ex) {
                      if (context.mounted) {
                        ToastHelper.showFailureToast(context, message: 'Failed to remove set from workout');
                      }
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
