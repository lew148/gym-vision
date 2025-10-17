import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';
import 'package:gymvision/widgets/forms/workout_set_form.dart';
import 'package:gymvision/widgets/pages/exercise/exercise_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final Function(int weId)? onDelete;
  final Function(int weId)? toggleDroppedParent;
  final bool dropped;
  final bool isInFuture;
  final bool isDisplay;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutExercise,
    this.onDelete,
    this.toggleDroppedParent,
    this.dropped = false,
    this.isInFuture = false,
    this.isDisplay = false,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  late Future<List<WorkoutSet>> workoutSetsFuture;
  late String exerciseIdentifier;
  late Exercise exercise;
  late bool dropped;
  late bool isDisplay;

  @override
  void initState() {
    super.initState();
    workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
    exerciseIdentifier = widget.workoutExercise.exerciseIdentifier;
    exercise = widget.workoutExercise.exercise ?? DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier)!;
    dropped = widget.dropped;
    isDisplay = widget.isDisplay;
  }

  void reload() => setState(() {
        workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
      });

  void onEditWorkoutSetTap(WorkoutSet ws) => showCloseableBottomSheet(
        context,
        WorkoutSetForm(
          exerciseIdentifier: exerciseIdentifier,
          workoutId: widget.workoutExercise.workoutId,
          onSuccess: reload,
          workoutSet: ws,
        ),
      );

  void onCopySetButtonTap(WorkoutSet ws) async {
    try {
      HapticFeedback.lightImpact();
      await WorkoutSetModel.insert(
        WorkoutSet(
          workoutExerciseId: ws.workoutExerciseId,
          weight: ws.weight,
          time: ws.time,
          distance: ws.distance,
          calsBurned: ws.calsBurned,
          reps: ws.reps,
          done: false,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed add set to workout: ${ex.toString()}');
    }

    reload();
  }

  void onAddSetsButtonTap() {
    showCloseableBottomSheet(
      context,
      WorkoutSetForm(
        exerciseIdentifier: exerciseIdentifier,
        workoutId: widget.workoutExercise.workoutId,
        onSuccess: () {
          setState(() {
            if (!dropped) dropped = true;
            workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
          });

          if (widget.toggleDroppedParent != null) widget.toggleDroppedParent!(widget.workoutExercise.id!);
        },
      ),
    );
  }

  List<Widget> getWeightedSetContents(WorkoutSet ws) => [
        Expanded(flex: 4, child: TextWithIcon.weight(ws.weight, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: TextWithIcon.reps(ws.reps, alignment: MainAxisAlignment.center)),
      ];

  List<Widget> getCardioSetContents(WorkoutSet ws) => [
        Expanded(flex: 4, child: TextWithIcon.setTime(ws.time, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: TextWithIcon.distance(ws.distance, alignment: MainAxisAlignment.center)),
        Expanded(flex: 3, child: TextWithIcon.caloriesBurned(ws.calsBurned, alignment: MainAxisAlignment.center)),
      ];

  Widget getSetWidgetInner(int setNumber, WorkoutSet set) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(children: [
                CustomCheckbox(value: set.done, onChangeAsync: isDisplay ? null : (value) => onSetDoneTap(set, value)),
                const Padding(padding: EdgeInsetsGeometry.all(5)),
                Text(
                  setNumber.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ]),
            ),
            ...(widget.workoutExercise.isCardio() ? getCardioSetContents(set) : getWeightedSetContents(set))
          ],
        ),
      );

  List<Widget> getSetWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [];

    final orderedSets = OrderingHelper.orderListById(sets, widget.workoutExercise.setOrder);
    for (int i = 0; i < orderedSets.length; i++) {
      final set = orderedSets[i];
      widgets.add(isDisplay
          ? getSetWidgetInner(i + 1, set)
          : InkWell(
              enableFeedback: false,
              onLongPress: () => OptionsMenu.showOptionsMenu(
                context,
                buttons: [
                  Button(
                    text: 'Copy Set',
                    icon: Icons.content_copy_rounded,
                    style: ButtonCustomStyle.primaryIconOnly(),
                    onTap: () => onCopySetButtonTap(set),
                  ),
                  Button(
                    text: 'Edit Set',
                    icon: Icons.edit_rounded,
                    style: ButtonCustomStyle.primaryIconOnly(),
                    onTap: () {
                      Navigator.pop(context);
                      onEditWorkoutSetTap(set);
                    },
                  ),
                  Button(
                    text: 'Delete Set',
                    icon: Icons.delete_rounded,
                    style: ButtonCustomStyle.redIconOnly(),
                    onTap: () => showDeleteConfirm(
                      context,
                      "set",
                      () => WorkoutSetModel.delete(set.id!),
                    ).then((x) {
                      if (mounted) Navigator.pop(context);
                      reload();
                    }),
                  ),
                ],
              ),
              onTap: () => onEditWorkoutSetTap(set),
              child: getSetWidgetInner(i + 1, set),
            ));
    }

    return widgets;
  }

  Future<bool> onWorkoutExerciseDoneTap(bool done, bool standalone) async {
    try {
      HapticFeedback.lightImpact();

      if (widget.isInFuture && done) {
        showSnackBar(context, 'Cannot complete sets in the future');
        return false;
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

  Future<bool> onSetDoneTap(WorkoutSet set, bool done) async {
    try {
      HapticFeedback.lightImpact();
      if (widget.isInFuture && done) {
        showSnackBar(context, 'Cannot complete sets in the future');
        return false;
      }

      set.done = done;
      final success = await WorkoutSetModel.update(set);
      if (!success) throw Exception();

      final settings = await UserSettingsModel.getUserSettings();
      if (done && settings.intraSetRestTimer != null && mounted) setRestTimer(context, settings.intraSetRestTimer!);

      reload();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Widget getHeader({required bool standalone, required bool isDone}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomCheckbox(
              value: isDone,
              onChangeAsync: isDisplay ? null : (value) => onWorkoutExerciseDoneTap(value, standalone),
            ),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: isDisplay
                      ? Column(children: [
                          TextWithIcon.date(widget.workoutExercise.workout!.date, muted: false),
                          TextWithIcon.time(
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
                    onTap: () => openWorkoutView(
                      context,
                      widget.workoutExercise.workoutId,
                      droppedWes: [widget.workoutExercise.id!],
                    ).then((x) => reload()),
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
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                    builder: (context) => ExerciseView(identifier: exerciseIdentifier),
                                  ))
                                  .then((value) => reload());
                            },
                            style: ButtonCustomStyle.primaryIconOnly(),
                          ),
                          Button.delete(
                            onTap: () {
                              Navigator.pop(context);
                              showDeleteConfirm(
                                context,
                                "exercise from workout",
                                () => WorkoutExerciseModel.delete(widget.workoutExercise.id!),
                              ).then((x) {
                                if (widget.onDelete != null) widget.onDelete!(widget.workoutExercise.id!);
                              });
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
        if (!snapshot.hasData) return const ShimmerLoad(height: 50);

        final sets = snapshot.data!;

        return CustomCard(
          child: sets.isEmpty
              ? getHeader(standalone: true, isDone: widget.workoutExercise.done)
              : Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        dropped = !dropped;
                      }),
                      behavior: HitTestBehavior.translucent,
                      child: getHeader(standalone: false, isDone: !(sets.any((ws) => !ws.done))),
                    ),
                    if (dropped) ...[
                      const CustomDivider(shadow: true, height: 0),
                      Column(children: getSetWidgets(sets)),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
