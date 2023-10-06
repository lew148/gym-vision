import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/shared/forms/add_set_to_workout_form.dart';
import 'package:gymvision/shared/forms/edit_workout_set_form.dart';
import 'package:gymvision/shared/ui_helper.dart';

import '../db/classes/exercise.dart';
import '../db/helpers/workout_sets_helper.dart';
import '../exercises/exercise_view.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final List<WorkoutSet> workoutSets;
  final Function() reloadState;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutSets,
    required this.reloadState,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  bool dropped = false;

  void onEditWorkoutExerciseTap(WorkoutSet ws) => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: EditWorkoutExerciseForm(
                workoutSet: ws,
                reloadState: widget.reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      );

  void onCopySetButtonTap(WorkoutSet ws) async {
    try {
      await WorkoutSetsHelper.addSetToWorkout(
        exerciseId: ws.exerciseId,
        workoutId: ws.workoutId,
        weight: ws.weight,
        reps: ws.reps,
        done: false,
      );
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed add set to workout: ${ex.toString()}',
          ),
        ),
      );
    }

    widget.reloadState();
  }

  void onAddSetsButtonTap(Exercise exercise, int workoutId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddSetToWorkoutForm(
              exerciseId: exercise.id,
              workoutId: workoutId,
              reloadState: widget.reloadState,
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    ).then((value) => widget.reloadState());
  }

  List<Widget> getWorkoutExerciseWidget(List<WorkoutSet> sets) {
    List<Widget> widgets = [];

    for (int i = 0; i < sets.length; i++) {
      final ws = sets[i];

      widgets.add(Column(children: [
        const Divider(height: 0),
        InkWell(
          onTap: () => onEditWorkoutExerciseTap(ws),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.shadow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (i + 1).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ws.hasWeight()
                          ? [
                              const Icon(
                                Icons.fitness_center_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(ws.getWeightString(showNone: false) ?? ''),
                            ]
                          : [
                              const Center(
                                child: Text(
                                  '-',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            ],
                    )),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.repeat_rounded,
                        size: 15,
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      Text(ws.getRepsDisplayString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]));
    }

    widgets.add(Row(children: [
      Expanded(
        child: getPrimaryButton(
          actionButton: ActionButton(
            icon: Icons.copy_rounded,
            onTap: () => onCopySetButtonTap(widget.workoutSets.last),
          ),
          padding: 0,
        ),
      ),
      Expanded(
        child: getPrimaryButton(
          actionButton: ActionButton(
            icon: Icons.add_rounded,
            onTap: () => onAddSetsButtonTap(
              widget.workoutSets[0].exercise!,
              widget.workoutSets[0].workoutId,
            ),
          ),
          padding: 0,
        ),
      ),
    ]));

    return widgets;
  }

  void onGroupedWorkoutExercisesDoneTap(bool? done) async {
    if (done == null) return;

    try {
      for (var ws in widget.workoutSets) {
        ws.done = done;
        await WorkoutSetsHelper.updateWorkoutSet(ws);
      }
    } catch (ex) {
      // ignore
    }

    widget.reloadState();
  }

  void showDeleteGroupedWorkoutExercisesConfirm() {
    Widget cancelButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text(
        "Yes",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        Navigator.pop(context);

        try {
          await WorkoutSetsHelper.removegroupedSetsFromWorkout(
            widget.workoutSets[0].workoutId,
            widget.workoutSets[0].exerciseId,
          );
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove Exercise from workout: ${ex.toString()}'),
            ),
          );
        }

        widget.reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Sets?"),
      content: const Text("Are you sure you would like to remove these sets?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() {
                  dropped = !dropped;
                }),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        checkColor: Colors.white,
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: widget.workoutSets.every((ws) => ws.done),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (bool? value) => onGroupedWorkoutExercisesDoneTap(value),
                      ),
                      Expanded(
                        child: Text(
                          widget.workoutSets[0].exercise!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            getPrimaryButton(
                              actionButton: ActionButton(
                                icon: Icons.visibility_rounded,
                                onTap: () => Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => ExerciseView(
                                          exerciseId: widget.workoutSets[0].exerciseId,
                                        ),
                                      ),
                                    )
                                    .then((value) => widget.reloadState()),
                              ),
                              padding: 0,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              onPressed: showDeleteGroupedWorkoutExercisesConfirm,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dropped) ...getWorkoutExerciseWidget(widget.workoutSets),
            ],
          ),
        ),
      ],
    );
  }
}
