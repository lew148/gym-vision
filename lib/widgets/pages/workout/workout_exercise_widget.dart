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
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';
import 'package:gymvision/widgets/forms/workout_set_form.dart';
import 'package:gymvision/widgets/pages/exercise/exercise_view.dart';
import 'package:gymvision/widgets/common_ui.dart';
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

  void toggleDropped() {
    setState(() {
      dropped = !dropped;
    });

    if (widget.toggleDroppedParent != null) widget.toggleDroppedParent!(widget.workoutExercise.id!);
  }

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
          dropped ? null : toggleDropped();
          reload();
        },
      ),
    );
  }

  List<Widget> getWeightedSetContents(WorkoutSet ws) => [
        Expanded(flex: 5, child: CommonUI.getWeightWithIcon(ws)),
        Expanded(flex: 5, child: CommonUI.getRepsWithIcon(ws)),
      ];

  List<Widget> getCardioSetContents(WorkoutSet ws) => [
        Expanded(flex: 4, child: CommonUI.getSetTimeWithIcon(ws)),
        Expanded(flex: 3, child: CommonUI.getDistanceWithIcon(ws)),
        Expanded(flex: 3, child: CommonUI.getCaloriesWithIcon(ws)),
      ];

  Widget getSetWidgetInner(int setNumber, WorkoutSet set) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(children: [
                CustomCheckbox(value: set.done, onChange: isDisplay ? null : (value) => onSetDoneTap(set, value)),
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
              onLongPress: () {
                HapticFeedback.lightImpact();
                showSetMenu(set);
              },
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

  void showExerciseMenu() {
    showCloseableBottomSheet(
      context,
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => ExerciseView(identifier: exerciseIdentifier)))
                    .then((value) => reload());
              },
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  const Text(
                    'View Exercise',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          CommonUI.getDivider(),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirm(
                  context,
                  "exercise from workout",
                  () => WorkoutExerciseModel.delete(widget.workoutExercise.id!),
                  () {
                    if (widget.onDelete != null) widget.onDelete!(widget.workoutExercise.id!);
                  },
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  const Text(
                    'Delete Exercise',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSetMenu(WorkoutSet ws) {
    showOptionsMenu(
      context,
      [
        ButtonDetails(
          text: 'Copy Set',
          icon: Icons.content_copy_rounded,
          style: ButtonDetailsStyle.primaryIcon(context),
          onTap: () => onCopySetButtonTap(ws),
        ),
        ButtonDetails(
          text: 'Edit Set',
          icon: Icons.edit_rounded,
          style: ButtonDetailsStyle.primaryIcon(context),
          onTap: () {
            Navigator.pop(context);
            onEditWorkoutSetTap(ws);
          },
        ),
        ButtonDetails(
          text: 'Delete Set',
          icon: Icons.delete_rounded,
          style: ButtonDetailsStyle.redIcon,
          onTap: () => showDeleteConfirm(
            context,
            "set",
            () => WorkoutSetModel.delete(ws.id!),
            reload,
            popCaller: true,
          ),
        ),
      ],
    );
  }

  Widget getHeader({required bool standalone, required bool isDone}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomCheckbox(
              value: isDone,
              onChange: isDisplay ? null : (value) => onWorkoutExerciseDoneTap(value, standalone),
            ),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: isDisplay
                      ? Column(children: [
                          CommonUI.getDateWithIcon(context, widget.workoutExercise.workout!.date, muted: false),
                          CommonUI.getTimeWithIcon(
                            context,
                            widget.workoutExercise.workout!.date,
                            dtEnd: widget.workoutExercise.workout?.endDate,
                          ),
                        ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                ? CommonUI.getTextButton(ButtonDetails(
                    icon: Icons.remove_red_eye_rounded,
                    onTap: () => openWorkoutView(
                          context,
                          widget.workoutExercise.workoutId,
                          reloadState: reload,
                          droppedWes: [widget.workoutExercise.id!],
                        )))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CommonUI.getTextButton(ButtonDetails(icon: Icons.add_rounded, onTap: onAddSetsButtonTap)),
                      GestureDetector(onTap: showExerciseMenu, child: const Icon(Icons.more_vert_rounded)),
                    ],
                  ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CommonUI.getCard(
      context,
      FutureBuilder(
        future: workoutSetsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final sets = snapshot.data!;
          if (sets.isEmpty) return getHeader(standalone: true, isDone: widget.workoutExercise.done);

          return Column(
            children: [
              GestureDetector(
                onTap: toggleDropped,
                behavior: HitTestBehavior.translucent,
                child: getHeader(standalone: false, isDone: !(sets.any((ws) => !ws.done))),
              ),
              if (dropped) ...[
                CommonUI.getShadowDivider(context, height: 0),
                Column(children: getSetWidgets(sets)),
              ],
            ],
          );
        },
      ),
    );
  }
}
