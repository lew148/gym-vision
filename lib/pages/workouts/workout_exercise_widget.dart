import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/exercises/exercise_view.dart';
import 'package:gymvision/pages/forms/add_set_to_workout_form.dart';
import 'package:gymvision/pages/forms/edit_workout_set_form.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/fields/custom_form_fields.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final Function() reloadParent;
  final Function(int wexId) toggleDroppedParent;
  final bool dropped;
  final bool isInFuture;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutExercise,
    required this.reloadParent,
    required this.toggleDroppedParent,
    this.dropped = false,
    this.isInFuture = false,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  late int workoutId;
  late String exerciseIdentifier;
  late Exercise exercise;
  late List<WorkoutSet> workoutSets;
  late bool dropped;
  late bool isDroppable;
  late bool isDone;

  @override
  void initState() {
    super.initState();
    workoutId = widget.workoutExercise.workoutId;
    exerciseIdentifier = widget.workoutExercise.exerciseIdentifier;
    exercise = widget.workoutExercise.exercise!;
    workoutSets = widget.workoutExercise.workoutSets ?? [];
    dropped = widget.dropped;
    isDroppable = workoutSets.isNotEmpty;
    isDone = widget.workoutExercise.done;
  }

  void toggleDropped() {
    setState(() {
      dropped = !dropped;
    });

    widget.toggleDroppedParent(widget.workoutExercise.id!);
  }

  void onEditWorkoutSetTap(WorkoutSet ws) => showCustomBottomSheet(
        context,
        EditWorkoutSetForm(
          workoutSet: ws,
          reloadState: widget.reloadParent,
          exerciseWithDetails: exercise,
        ),
      );

  void onCopySetButtonTap(WorkoutSet ws) async {
    try {
      HapticFeedback.heavyImpact();
      await WorkoutSetModel.addSetToWorkout(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed add set to workout: ${ex.toString()}')));
    }

    widget.reloadParent();
  }

  void onAddSetsButtonTap() {
    showCustomBottomSheet(
      context,
      AddSetToWorkoutForm(
        exerciseIdentifier: exerciseIdentifier,
        workoutId: workoutId,
        reloadState: widget.reloadParent,
        onSuccess: () => dropped ? null : toggleDropped(),
      ),
    );
  }

  List<Widget> getWeightedSetContents(WorkoutSet ws) => [
        Expanded(flex: 5, child: CommonUI.getWeightWithIcon(ws)),
        Expanded(flex: 5, child: CommonUI.getRepsWithIcon(ws)),
      ];

  List<Widget> getCardioSetContents(WorkoutSet ws) => [
        Expanded(flex: 4, child: CommonUI.getTimeWithIcon(ws)),
        Expanded(flex: 3, child: CommonUI.getDistanceWithIcon(ws)),
        Expanded(flex: 3, child: CommonUI.getCaloriesWithIcon(ws)),
      ];

  List<Widget> getSetWidgets() {
    final List<Widget> widgets = [];

    for (int i = 0; i < workoutSets.length; i++) {
      final ws = workoutSets[i];
      widgets.add(InkWell(
        enableFeedback: false,
        onLongPress: () {
          HapticFeedback.heavyImpact();
          showSetMenu(ws);
        },
        onTap: () => onEditWorkoutSetTap(ws),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (i + 1).toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...(widget.workoutExercise.isCardio() ? getCardioSetContents(ws) : getWeightedSetContents(ws))
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  void onWorkoutExerciseDoneTap(bool done) async {
    try {
      HapticFeedback.heavyImpact();

      if (widget.isInFuture && done) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot mark future sets done!')));
        return;
      }

      widget.workoutExercise.done = done;
      await WorkoutExerciseModel.updateWorkoutExercise(widget.workoutExercise);

      setState(() {
        isDone = done;
      });
    } catch (ex) {
      // ignore
    }

    // widget.reloadParent();
  }

  void showExerciseMenu() {
    showCustomBottomSheet(
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
                    .then((value) => widget.reloadParent());
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
                  () => WorkoutExerciseModel.deleteWorkoutExercise(widget.workoutExercise.id!),
                  widget.reloadParent,
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
          onTap: () => onCopySetButtonTap(ws),
        ),
        ButtonDetails(
          text: 'Edit Set',
          icon: Icons.edit_rounded,
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
            () => WorkoutSetModel.removeSet(ws.id!),
            widget.reloadParent,
            popCaller: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonUI.getCard(
      context,
      Column(
        children: [
          GestureDetector(
            onTap: toggleDropped,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomFormFields.checkbox(
                    context,
                    isDone,
                    (bool? value) => onWorkoutExerciseDoneTap(value!),
                  ),
                  Expanded(
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(children: [
                              if (exercise.equipment != Equipment.other)
                                Text(exercise.equipment.displayName,
                                    style: TextStyle(color: Theme.of(context).colorScheme.shadow)),
                            ]),
                          ],
                        ),
                      ),
                      if (isDroppable)
                        dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CommonUI.getTextButton(
                        ButtonDetails(
                          icon: Icons.add_rounded,
                          onTap: onAddSetsButtonTap,
                        ),
                      ),
                      GestureDetector(
                        onTap: showExerciseMenu,
                        child: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isDroppable && dropped) ...[
            CommonUI.getDivider(height: 0),
            ...getSetWidgets(),
          ],
        ],
      ),
    );
  }
}
