import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/helpers/functions/workout_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/providers/workout_stats_provider.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/workouts/workout_set_widget.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';
import 'package:gymvision/widgets/forms/workout_set_form.dart';
import 'package:gymvision/widgets/pages/exercise/exercise_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:provider/provider.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final Function(int weId)? onDelete;
  final Function(int weId)? onDrop;
  final bool isInFuture;
  final bool isDisplay;
  final bool dropped;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutExercise,
    this.onDelete,
    this.onDrop,
    this.isInFuture = false,
    this.isDisplay = false,
    this.dropped = false,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  late Future<List<WorkoutSet>> workoutSetsFuture;
  late String exerciseIdentifier;
  late Exercise exercise;
  late bool isDisplay;
  late bool dropped;

  @override
  void initState() {
    super.initState();
    workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(
      widget.workoutExercise.id!,
      exerciseIdentifier: widget.workoutExercise.exerciseIdentifier,
    );
    exerciseIdentifier = widget.workoutExercise.exerciseIdentifier;
    exercise = widget.workoutExercise.exercise ?? DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier)!;
    isDisplay = widget.isDisplay;
    dropped = widget.dropped;
  }

  void reload() => setState(() {
        workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(
          widget.workoutExercise.id!,
          exerciseIdentifier: widget.workoutExercise.exerciseIdentifier,
        );
        
        context.read<WorkoutStatsProvider>().reload();
      });

  void onAddSetsButtonTap() async {
    await BottomSheetHelper.showCloseableBottomSheet(
      context,
      WorkoutSetForm(
        exerciseIdentifier: exerciseIdentifier,
        workoutId: widget.workoutExercise.workoutId,
        onSuccess: () {
          setState(() {
            if (!dropped) dropped = true;
            workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(
              widget.workoutExercise.id!,
              exerciseIdentifier: widget.workoutExercise.exerciseIdentifier,
            );
          });

          if (widget.onDrop != null) widget.onDrop!(widget.workoutExercise.id!);
        },
      ),
    );
  }

  List<Widget> getSetWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [];

    final orderedSets = OrderingHelper.sortByOrder(sets, widget.workoutExercise.setOrder);
    for (int i = 0; i < orderedSets.length; i++) {
      widgets.add(WorkoutSetWidget(
        set: orderedSets[i],
        reloadParent: reload,
        isDisplay: isDisplay,
        isCardio: exercise.isCardio(),
        isInFuture: widget.isInFuture,
        exerciseIdentifier: exerciseIdentifier,
        workoutId: widget.workoutExercise.workoutId,
        setNumber: i + 1,
      ));
    }

    return widgets;
  }

  Future<bool> onWorkoutExerciseDoneTap(bool done, bool standalone, List<WorkoutSet>? sets) async {
    try {
      HapticFeedback.lightImpact();

      if (done) {
        if (widget.isInFuture) {
          ToastHelper.showDisallowedToast(context, message: 'Cannot complete sets in the future!');
          return false;
        }

        if (!exercise.isCardio() && sets != null && sets.any((s) => s.reps == null || s.reps == 0)) {
          ToastHelper.showDisallowedToast(context, message: 'Sets must have reps to be completed!');
          return false;
        }
      }

      if (standalone) {
        widget.workoutExercise.done = done;
        final success = await WorkoutExerciseModel.update(widget.workoutExercise);
        if (!success) throw Exception();
        return true;
      }

      final success = await WorkoutExerciseModel.markAllSetsDone(widget.workoutExercise.id!, done);
      if (!success) throw Exception();

      reload();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Widget getHeader({required bool standalone, List<WorkoutSet>? sets}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomCheckbox(
              value: sets != null ? sets.every((ws) => ws.done) : widget.workoutExercise.isDone(),
              onChangeAsync: isDisplay ? null : (value) => onWorkoutExerciseDoneTap(value, standalone, sets),
            ),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: isDisplay
                      ? Column(children: [
                          StatDisplay.date(widget.workoutExercise.workout!.date, muted: false),
                          StatDisplay.time(
                            widget.workoutExercise.workout!.date,
                            dtEnd: widget.workoutExercise.workout?.endDate,
                          ),
                        ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (exercise.equipment != Equipment.other)
                              Text(
                                exercise.equipment.displayName,
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                          ],
                        ),
                ),
                if (!standalone)
                  dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
              ]),
            ),
            isDisplay
                ? Button(
                    icon: Icons.remove_red_eye_rounded,
                    onTap: () async {
                      await WorkoutHelper.openWorkoutView(
                        context,
                        widget.workoutExercise.workoutId,
                        focusedWorkoutExerciseId: widget.workoutExercise.id!,
                      );

                      reload();
                    },
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(icon: Icons.add_rounded, onTap: onAddSetsButtonTap),
                      OptionsMenu(
                        title: exercise.getFullName(),
                        buttons: [
                          Button(
                            icon: Icons.visibility_rounded,
                            text: 'View Exercise',
                            onTap: () async {
                              Navigator.pop(context);
                              await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ExerciseView(identifier: exerciseIdentifier),
                              ));

                              reload();
                            },
                            style: ButtonCustomStyle.primaryIconOnly(),
                          ),
                          Button.delete(
                            onTap: () async {
                              Navigator.pop(context);
                              await DialogHelper.showDeleteConfirm(
                                context,
                                "exercise from workout",
                                () => WorkoutExerciseModel.delete(widget.workoutExercise.id!),
                              );

                              if (widget.onDelete != null) {
                                widget.onDelete!(widget.workoutExercise.id!);
                              }
                            },
                            text: 'Delete Exercise',
                          )
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: workoutSetsFuture,
      builder: (context, snapshot) {
        final sets = snapshot.data;
        return ShimmerLoad(
          height: dropped ? 100 : 50,
          loading: snapshot.connectionState == ConnectionState.waiting,
          child: CustomCard(
            child: sets == null || sets.isEmpty
                ? getHeader(standalone: true)
                : Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (widget.onDrop != null) {
                            widget.onDrop!(widget.workoutExercise.id!);
                          }
                          setState(() {
                            dropped = !dropped;
                          });
                        },
                        behavior: HitTestBehavior.translucent,
                        child: getHeader(standalone: false, sets: sets),
                      ),
                      if (dropped) ...[
                        const CustomDivider(shadow: true, height: 0),
                        Column(children: getSetWidgets(sets)),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
