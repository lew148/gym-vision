import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/db/classes/workout.dart';
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
  late int workoutId;
  late Workout workout;
  late int exerciseId;
  late Exercise exercise;
  late List<WorkoutSet> realWorkoutSets;
  late bool onlyPlaceholderSets;
  late bool dropped;

  @override
  void initState() {
    super.initState();
    workoutId = widget.workoutSets[0].workoutId;
    workout = widget.workoutSets[0].workout!;
    exerciseId = widget.workoutSets[0].exerciseId;
    exercise = widget.workoutSets[0].exercise!;
    realWorkoutSets = widget.workoutSets.where((ws) => ws.hasWeight() || ws.hasReps() || ws.isCardio()).toList();
    onlyPlaceholderSets = realWorkoutSets.isEmpty;
    dropped = realWorkoutSets.isNotEmpty && widget.dropped;
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
      HapticFeedback.heavyImpact();
      await WorkoutSetsHelper.addSetToWorkout(
        WorkoutSet(
          exerciseId: ws.exerciseId,
          workoutId: ws.workoutId,
          weight: ws.weight,
          time: ws.time,
          distance: ws.distance,
          calsBurned: ws.calsBurned,
          reps: ws.reps,
          single: ws.single,
          done: false,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed add set to workout: ${ex.toString()}')));
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
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
              Expanded(
                flex: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.more_vert_rounded),
                  ),
                  onTap: () => showSetMenu(ws),
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

  List<Widget> getWorkoutExerciseWidgets(List<WorkoutSet> sets, bool useHeading) {
    final List<Widget> widgets = [const Divider(height: 0, thickness: 0.25)];

    if (useHeading && sets[0].isSingle()) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Text(
            'Single',
            style: TextStyle(
              color: Theme.of(context).colorScheme.shadow,
              fontWeight: FontWeight.bold,
            ),
          )
        ]),
      ));
    }

    var setWidgets = sets.first.isCardio() ? getCardioSetWidgets(sets) : getWeightedSetWidgets(sets);
    widgets.addAll(setWidgets);
    return widgets;
  }

  void onGroupedWorkoutExercisesDoneTap(bool done) async {
    try {
      HapticFeedback.heavyImpact();

      if (workout.isInFuture()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot mark future sets done!'),
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
            workoutId,
            exerciseId,
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

    HapticFeedback.heavyImpact();
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

  void showExerciseMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (context) => ExerciseView(exerciseId: exerciseId),
                      ))
                      .then((value) => widget.reloadState());
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
            const Divider(thickness: 0.25),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showDeleteGroupedWorkoutExercisesConfirm();
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
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  void showSetMenu(WorkoutSet ws) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () => onCopySetButtonTap(ws),
                child: Row(
                  children: [
                    Icon(
                      Icons.content_copy_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    const Text(
                      'Copy Set',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 0.25),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onEditWorkoutExerciseTap(ws);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    const Text(
                      'Edit Set',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 0.25),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showDeleteWorkoutSetConfirm(ws.id!);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    const Text(
                      'Delete Set',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: onlyPlaceholderSets ? null : () => widget.reloadState(eId: exerciseId),
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
                          '${exercise.uniAndBiLateral && realWorkoutSets.isNotEmpty && realWorkoutSets.every((ws) => ws.isSingle()) ? 'Single ' : ''}${exercise.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!onlyPlaceholderSets)
                        dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      getPrimaryButton(
                        ActionButton(
                          icon: Icons.add_rounded,
                          onTap: () => onAddSetsButtonTap(
                            exercise,
                            workoutId,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: showExerciseMenu,
                        child: const Icon(
                          Icons.more_vert_rounded,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (dropped && widget.workoutSets.any((ws) => !ws.isSingle()))
            ...getWorkoutExerciseWidgets(widget.workoutSets.where((ws) => !ws.isSingle()).toList(), false),
          if (dropped && widget.workoutSets.any((ws) => ws.isSingle()))
            ...getWorkoutExerciseWidgets(
                widget.workoutSets.where((ws) => ws.isSingle()).toList(), realWorkoutSets.any((ws) => !ws.isSingle())),
        ],
      ),
    );
  }
}
