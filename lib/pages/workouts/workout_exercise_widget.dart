import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/shared/forms/add_set_to_workout_form.dart';
import 'package:gymvision/shared/forms/edit_workout_set_form.dart';
import 'package:gymvision/shared/ui_helper.dart';

import '../../db/classes/exercise.dart';
import '../../db/helpers/workout_sets_helper.dart';
import '../exercises/exercise_view.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final List<WorkoutSet> workoutSets;
  final Function({int? eId}) reloadState;
  final bool dropped;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutSets,
    required this.reloadState,
    this.dropped = false,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  late bool dropped;

  @override
  void initState() {
    super.initState();
    dropped = widget.dropped;
  }

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
        WorkoutSet(
          exerciseId: ws.exerciseId,
          workoutId: ws.workoutId,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed add set to workout: ${ex.toString()}')),
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

  Widget dashIcon() => const Center(
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  List<Widget> getWeightedSetWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [];
    final filteredSets = sets.where((ws) => ws.hasWeight() || ws.hasReps()).toList();

    for (int i = 0; i < filteredSets.length; i++) {
      final ws = filteredSets[i];

      widgets.add(InkWell(
        onLongPress: () => showDeleteWorkoutSetConfirm(ws.id!),
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
                            Text(ws.getWeightDisplay()),
                          ]
                        : [dashIcon()],
                  )),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ws.reps != null && ws.reps! > 0
                      ? [
                          const Icon(
                            Icons.repeat_rounded,
                            size: 15,
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(ws.getRepsDisplay()),
                        ]
                      : [dashIcon()],
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  List<Widget> getCardioSetWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [];
    final filteredSets = sets.where((ws) => ws.hasTime() || ws.hasDistance() || ws.hasCalsBurned()).toList();

    if (filteredSets.isNotEmpty) widgets.add(const Padding(padding: EdgeInsets.all(2)));

    for (int i = 0; i < filteredSets.length; i++) {
      final ws = filteredSets[i];

      widgets.add(InkWell(
        onLongPress: () => showDeleteWorkoutSetConfirm(ws.id!),
        onTap: () => onEditWorkoutExerciseTap(ws),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ws.hasTime()
                        ? [
                            const Icon(
                              Icons.timer_rounded,
                              size: 15,
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            Text(ws.getTimeDisplay()),
                          ]
                        : [dashIcon()],
                  )),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ws.hasDistance()
                      ? [
                          const Icon(
                            Icons.timeline_rounded,
                            size: 15,
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(ws.getDistanceDisplay()),
                        ]
                      : [dashIcon()],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ws.hasCalsBurned()
                      ? [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 15,
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(ws.getCalsBurnedDisplay()),
                        ]
                      : [dashIcon()],
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  List<Widget> getWorkoutExerciseWidgets(List<WorkoutSet> sets) {
    final List<Widget> widgets = [const Divider(height: 0, thickness: 0.25)];

    var setWidgets = sets.first.isCardio() ? getCardioSetWidgets(sets) : getWeightedSetWidgets(sets);
    widgets.addAll(setWidgets);

    widgets.add(Row(children: [
      if (setWidgets.isNotEmpty)
        Expanded(
          child: getPrimaryButton(
            ActionButton(
              icon: Icons.copy_rounded,
              onTap: () => onCopySetButtonTap(widget.workoutSets.last),
            ),
          ),
        ),
      Expanded(
        child: getPrimaryButton(
          ActionButton(
            icon: Icons.add_rounded,
            onTap: () => onAddSetsButtonTap(
              widget.workoutSets[0].exercise!,
              widget.workoutSets[0].workoutId,
            ),
          ),
        ),
      ),
    ]));

    return widgets;
  }

  void onGroupedWorkoutExercisesDoneTap(bool done) async {
    try {
      HapticFeedback.heavyImpact();

      if (widget.workoutSets[0].workout!.isInFuture()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot complete sets. Workout is in the future!'),
        ));
        return;
      }

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
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to remove Exercise from workout: ${ex.toString()}')));
        }

        widget.reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Sets?"),
      content: const Text("Are you sure you would like to remove these sets?"),
      backgroundColor: Theme.of(context).cardColor,
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

  void showDeleteWorkoutSetConfirm(int id) {
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
          await WorkoutSetsHelper.removeSet(id);
        } catch (ex) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to remove Set from workout: ${ex.toString()}')));
        }

        widget.reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Set?"),
      content: const Text("Are you sure you would like to remove this set?"),
      backgroundColor: Theme.of(context).cardColor,
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () => widget.reloadState(eId: widget.workoutSets[0].exerciseId),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    checkColor: Colors.white,
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: widget.workoutSets.every((ws) => ws.done),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (bool? value) => onGroupedWorkoutExercisesDoneTap(value!),
                  ),
                  Expanded(
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          widget.workoutSets[0].exercise!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      getPrimaryButton(
                        ActionButton(
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
                ],
              ),
            ),
          ),
          if (dropped) ...getWorkoutExerciseWidgets(widget.workoutSets),
        ],
      ),
    );
  }
}
