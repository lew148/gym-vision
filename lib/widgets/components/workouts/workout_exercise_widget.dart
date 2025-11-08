import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
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
    workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
    exerciseIdentifier = widget.workoutExercise.exerciseIdentifier;
    exercise = widget.workoutExercise.exercise ?? DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier)!;
    isDisplay = widget.isDisplay;
    dropped = widget.dropped;
  }

  void reload() => setState(() {
        workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
      });

  void onEditWorkoutSetTap(WorkoutSet ws) async => await showCloseableBottomSheet(
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

  void onAddSetsButtonTap() async {
    await showCloseableBottomSheet(
      context,
      WorkoutSetForm(
        exerciseIdentifier: exerciseIdentifier,
        workoutId: widget.workoutExercise.workoutId,
        onSuccess: () {
          setState(() {
            if (!dropped) dropped = true;
            workoutSetsFuture = WorkoutSetModel.getSetsForWorkoutExercise(widget.workoutExercise.id!);
          });

          if (widget.onDrop != null) widget.onDrop!(widget.workoutExercise.id!);
        },
      ),
    );
  }

  Widget getCheckAndIndex(int flex, WorkoutSet set, int setNumber) => Expanded(
        flex: flex,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomCheckbox(
              value: set.done,
              onChangeAsync: isDisplay ? null : (value) => onSetDoneTap(set, value),
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

  List<Widget> getWeightedSetContents(WorkoutSet ws, int setNumber) => [
        getCheckAndIndex(4, ws, setNumber),
        Expanded(flex: 4, child: TextWithIcon.weight(ws.weight, alignment: MainAxisAlignment.start)),
        Expanded(flex: 4, child: TextWithIcon.reps(ws.reps, alignment: MainAxisAlignment.start)),
      ];

  List<Widget> getCardioSetContents(WorkoutSet ws, int setNumber) => [
        getCheckAndIndex(2, ws, setNumber),
        Expanded(flex: 4, child: TextWithIcon.duration(ws.time, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: TextWithIcon.distance(ws.distance, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: TextWithIcon.caloriesBurned(ws.calsBurned, alignment: MainAxisAlignment.center)),
      ];

  Widget getSetWidgetInner(WorkoutSet set, int setNumber) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: widget.workoutExercise.isCardio()
              ? getCardioSetContents(set, setNumber)
              : getWeightedSetContents(set, setNumber),
        ),
      );

  List<Widget> getSetWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [];

    final orderedSets = OrderingHelper.sortByOrder(sets, widget.workoutExercise.setOrder);
    for (int i = 0; i < orderedSets.length; i++) {
      final set = orderedSets[i];
      widgets.add(isDisplay
          ? getSetWidgetInner(set, i + 1)
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
                    onTap: () {
                      showDeleteConfirm(context, "set", () => WorkoutSetModel.delete(set.id!));
                      if (mounted) Navigator.pop(context);
                      reload();
                    },
                  ),
                ],
              ),
              onTap: () => onEditWorkoutSetTap(set),
              child: getSetWidgetInner(set, i + 1),
            ));
    }

    return widgets;
  }

  Future<bool> onWorkoutExerciseDoneTap(bool done, bool standalone, List<WorkoutSet>? sets) async {
    try {
      HapticFeedback.lightImpact();

      if (done) {
        if (widget.isInFuture) {
          showSnackBar(context, 'Cannot complete sets in the future');
          return false;
        }

        if (!exercise.isCardio() && sets != null && sets.any((s) => s.reps == null || s.reps == 0)) {
          showSnackBar(context, 'Sets must have reps');
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

  Future<bool> onSetDoneTap(WorkoutSet set, bool done) async {
    try {
      HapticFeedback.lightImpact();

      if (done) {
        if (widget.isInFuture) {
          showSnackBar(context, 'Cannot complete sets in the future');
          return false;
        }

        if (!exercise.isCardio() && (set.reps == null || set.reps == 0)) {
          showSnackBar(context, 'Sets must have reps');
          return false;
        }
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
                    onTap: () async {
                      await openWorkoutView(
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
                              await showDeleteConfirm(
                                context,
                                "exercise from workout",
                                () => WorkoutExerciseModel.delete(widget.workoutExercise.id!),
                              );

                              if (widget.onDelete != null) widget.onDelete!(widget.workoutExercise.id!);
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
                          if (widget.onDrop != null) widget.onDrop!(widget.workoutExercise.id!);
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
