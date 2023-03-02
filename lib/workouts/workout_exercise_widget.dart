import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/shared/forms/add_exercise_to_workout_form.dart';
import 'package:gymvision/shared/forms/edit_workout_exercise_form.dart';
import 'package:gymvision/shared/ui_helper.dart';

import '../db/classes/exercise.dart';
import '../db/helpers/workouts_helper.dart';
import '../exercises/exercise_view.dart';

class WorkoutExerciseWidget extends StatefulWidget {
  final List<WorkoutExercise> workoutExercises;
  final Function() reloadState;
  final bool displayOnly;

  const WorkoutExerciseWidget({
    super.key,
    required this.workoutExercises,
    required this.reloadState,
    this.displayOnly = false,
  });

  @override
  State<WorkoutExerciseWidget> createState() => _WorkoutExerciseWidgetState();
}

class _WorkoutExerciseWidgetState extends State<WorkoutExerciseWidget> {
  bool dropped = false;

  void onEditWorkoutExerciseTap(WorkoutExercise we) => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: EditWorkoutExerciseForm(
                workoutExercise: we,
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

  void onSplitASetTap(WorkoutExercise we) async {
    try {
      if (we.sets == null || we.sets! <= 0) {
        throw Exception('Cannot Split a Workout Exercise with no Sets');
      }

      if (we.sets == 1) {
        throw Exception('Cannot Split a Workout Exercise with only 1 Set');
      }

      await WorkoutsHelper.splitAWorkoutExerciseSet(we);
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ex.toString()),
        ),
      );
    }

    widget.reloadState();
  }

  void showMoreMenu(WorkoutExercise we) async {
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
                  onSplitASetTap(we);
                },
                child: Row(
                  children: const [
                    Icon(Icons.move_down_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Split a Set',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () async {
                  Navigator.pop(context);

                  try {
                    await WorkoutsHelper.removeExerciseFromWorkout(we.id!);
                  } catch (ex) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to remove Set from workout: ${ex.toString()}',
                        ),
                      ),
                    );
                  }

                  widget.reloadState();
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Remove from Workout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
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
            child: AddExerciseToWorkoutForm(
              exerciseId: exercise.id,
              workoutId: workoutId,
              reloadState: widget.reloadState,
              disableWorkoutPicker: true,
              disableExercisePicker: true,
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

  List<Widget> getWorkoutExerciseWidget(List<WorkoutExercise> wes) {
    wes.sort((a, b) => b.getWeight().compareTo(a.getWeight()));

    List<Widget> widgets = wes.map((we) {
      String getRepsString() {
        int reps = we.reps ?? we.exercise!.reps;
        return '$reps rep${reps == 1 ? '' : 's'}';
      }

      return Column(children: [
        const Divider(height: 0),
        InkWell(
          onTap: widget.displayOnly ? null : () => onEditWorkoutExerciseTap(we),
          child: Padding(
            padding: widget.displayOnly ? const EdgeInsets.all(15) : const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(child: Text('${we.sets!} x')),
                ),
                Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: we.hasWeight()
                          ? [
                              const Icon(
                                Icons.fitness_center_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text((widget.displayOnly
                                      ? we.getNumberedWeightString(showNone: false)
                                      : we.getWeightString(showNone: false)) ??
                                  ''),
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
                      Text(getRepsString()),
                    ],
                  ),
                ),
                if (!widget.displayOnly)
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: IconButton(
                            splashRadius: 20,
                            onPressed: () => showMoreMenu(we),
                            icon: const Icon(Icons.more_vert_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]);
    }).toList();

    if (!widget.displayOnly) {
      widgets.add(Column(children: [
        getPrimaryButton(
          actionButton: ActionButton(
            icon: Icons.add_rounded,
            onTap: () => onAddSetsButtonTap(
              widget.workoutExercises[0].exercise!,
              widget.workoutExercises[0].workoutId,
            ),
          ),
          padding: 0,
        )
      ]));
    }

    return widgets;
  }

  void onGroupedWorkoutExercisesDoneTap(bool? done) async {
    if (done == null) return;

    try {
      for (var we in widget.workoutExercises) {
        we.done = done;
        await WorkoutsHelper.updateWorkoutExercise(
          we,
        );
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
          await WorkoutsHelper.removegroupedExercisesFromWorkout(
              widget.workoutExercises[0].workoutId, widget.workoutExercises[0].exerciseId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to remove Exercises from workout: ${ex.toString()}',
              ),
            ),
          );
        }

        widget.reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete Exercise?"),
      content: const Text("Are you sure you would like to delete this exercise?"),
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

  void showHeaderMoreMenu() {
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
                  showDeleteGroupedWorkoutExercisesConfirm();
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Remove from Workout',
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
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.displayOnly
                          ? Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                widget.workoutExercises[0].workout!.getDateAndTimeString(),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            )
                          : Row(
                              children: [
                                Checkbox(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  value: widget.workoutExercises[0].done,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  onChanged: (bool? value) => onGroupedWorkoutExercisesDoneTap(value),
                                ),
                                Text(
                                  widget.workoutExercises[0].exercise!.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                dropped
                                    ? const Icon(Icons.arrow_drop_up_rounded)
                                    : const Icon(Icons.arrow_drop_down_rounded)
                              ],
                            ),
                      if (!widget.displayOnly)
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
                                            exerciseId: widget.workoutExercises[0].exerciseId,
                                            exerciseName: widget.workoutExercises[0].exercise!.name,
                                          ),
                                        ),
                                      )
                                      .then((value) => widget.reloadState()),
                                ),
                                padding: 0,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                ),
                                onPressed: showHeaderMoreMenu,
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.displayOnly || dropped) ...getWorkoutExerciseWidget(widget.workoutExercises),
            ],
          ),
        ),
      ],
    );
  }
}
