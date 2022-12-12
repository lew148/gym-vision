import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/shared/forms/add_exercise_to_workout_form.dart';
import 'package:gymvision/shared/forms/edit_workout_exercise_form.dart';

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
  var tapped = false;

  void showRemoveExerciseFromWorkoutConfirm(int workoutExerciseId) {
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
          await WorkoutsHelper.removeExerciseFromWorkout(workoutExerciseId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to remove Exercise from workout: ${ex.toString()}',
              ),
            ),
          );
        }

        widget.reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Exercise from Workout?"),
      content: const Text(
        "Are you sure you would like to remove this Exercise from this workout?",
      ),
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
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => ExerciseView(
                            exerciseId: we.exerciseId,
                            exerciseName: we.exercise!.name,
                          ),
                        ),
                      )
                      .then((value) => widget.reloadState());
                },
                child: Row(
                  children: const [
                    Icon(Icons.visibility_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'View Exercise',
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
                onTap: () {
                  Navigator.pop(context);
                  showRemoveExerciseFromWorkoutConfirm(we.id!);
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

      String getSetsString() {
        int sets = we.sets!;
        return '$sets set${sets == 1 ? '' : 's'}';
      }

      return Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: InkWell(
          onTap: widget.displayOnly ? null : () => onEditWorkoutExerciseTap(we),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: we.hasWeight()
                        ? Row(
                            children: [
                              const Icon(
                                Icons.fitness_center_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(we.getNumberedWeightString(showNone: false) ?? ''),
                            ],
                          )
                        : const Center(
                            child: Text(
                              '-',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
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
                  Expanded(
                    flex: 3,
                    child: Text(getSetsString()),
                  ),
                  if (!widget.displayOnly)
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        splashRadius: 20,
                        onPressed: () => showMoreMenu(we),
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();

    if (widget.displayOnly) return widgets; // no add button on display

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: InkWell(
          onTap: () => onAddSetsButtonTap(wes[0].exercise!, wes[0].workoutId),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Padding(padding: EdgeInsets.all(2)),
                  Text(
                    'Add Sets',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not set Workout Exercises ${done ? '' : 'not '}done: $ex',
          ),
        ),
      );
    }

    widget.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            tapped = !tapped;
          }),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.displayOnly
                      ? Text(
                          widget.workoutExercises[0].workout!
                              .getDateAndTimeString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                      : Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              value: widget.workoutExercises[0].done,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              onChanged: (bool? value) =>
                                  onGroupedWorkoutExercisesDoneTap(value),
                            ),
                            Text(
                              widget.workoutExercises[0].exercise!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                  Icon(
                    tapped ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                    size: 30,
                  )
                ],
              ),
            ),
          ),
        ),
        if (tapped) ...getWorkoutExerciseWidget(widget.workoutExercises),
      ],
    );
  }
}
