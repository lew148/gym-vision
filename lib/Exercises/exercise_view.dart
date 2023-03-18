import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/exercises/exercise_more_menu_button.dart';

import '../db/helpers/exercises_helper.dart';
import '../enums.dart';
import '../shared/ui_helper.dart';
import '../shared/forms/edit_exercise_field_form.dart';
import '../workouts/workout_exercise_widget.dart';

class ExerciseView extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;
  const ExerciseView(
      {super.key, required this.exerciseId, required this.exerciseName});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  reloadState() => setState(() {});

  Widget getExerciseViewWidget(Exercise exercise) =>
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: getValueDisplay(
                'Weight',
                Text(
                  exercise.getWeightString() ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                () => openEditExerciseFieldForm(
                  exercise,
                  ExerciseEditableField.weight,
                  'Weight',
                  exercise.getWeightAsString() ?? '',
                ),
              ),
            ),
            Expanded(
              child: getValueDisplay(
                'Max',
                Text(
                  exercise.getMaxString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                () => openEditExerciseFieldForm(
                  exercise,
                  ExerciseEditableField.max,
                  'Max',
                  exercise.getMaxAsString() ?? '',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: getValueDisplay(
                'Reps',
                Text(
                  exercise.getRepsString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                () => openEditExerciseFieldForm(
                  exercise,
                  ExerciseEditableField.reps,
                  'Reps',
                  exercise.reps.toString(),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Container(
                  height: 60.00,
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Double Sided'),
                      Switch(
                        value: !exercise.isSingle,
                        onChanged: (newValue) async {
                          exercise.isSingle = !exercise.isSingle;
                          await ExercisesHelper.updateExercise(exercise);
                          reloadState();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => openNotesForm(exercise),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: const [
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(exercise.notes == ''
                                      ? '-'
                                      : exercise.notes),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]);

  void openEditExerciseFieldForm(
    Exercise exercise,
    ExerciseEditableField editableField,
    String label,
    String currentValue,
  ) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: EditExerciseFieldForm(
                exercise: exercise,
                editableField: editableField,
                label: label,
                currentValue: currentValue,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      );

  void openNotesForm(Exercise exercise) {
    var controller = TextEditingController(text: exercise.notes);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Edit Notes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Column(
                      children: [
                        TextFormField(
                          controller: controller,
                          textInputAction: TextInputAction.go,
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add notes here',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);

                                  try {
                                    var newValue = controller.text;
                                    if (exercise.notes == newValue) return;

                                    exercise.notes = newValue;

                                    await ExercisesHelper.updateExercise(
                                        exercise);
                                  } catch (ex) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Failed to edit Notes')));
                                  }

                                  reloadState();
                                },
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  Widget getValueDisplay(String label, Widget widget, Function() onTap) => Card(
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 60.00,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                Row(
                  children: [
                    widget,
                    const Padding(padding: EdgeInsets.all(5)),
                    const Icon(
                      Icons.edit_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> getRecentUsesWidget(List<WorkoutExercise> workoutExercises) {
    workoutExercises
        .sort(((a, b) => b.workout!.date.compareTo(a.workout!.date)));

    final Map<int, List<WorkoutExercise>> groupedWorkoutExercises =
        groupBy<WorkoutExercise, int>(
      workoutExercises,
      (x) => x.workoutId,
    );

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: WorkoutExerciseWidget(
            workoutExercises: value,
            reloadState: reloadState,
            displayOnly: true,
          ),
        ),
      );
    });

    return weWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final Future<Exercise> exercise =
        ExercisesHelper.getExercise(widget.exerciseId);
    final Future<List<WorkoutExercise>?> workoutExercises =
        WorkoutsHelper.getWorkoutExercisesForExercise(widget.exerciseId);

    return FutureBuilder<Exercise>(
      future: exercise,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Loading...'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.data!.name),
            actions: [
              ExerciseMoreMenuButton(
                exercise: snapshot.data!,
                reloadState: reloadState,
                onDelete: () => Navigator.pop(context),
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: getExerciseViewWidget(snapshot.data!),
              ),
              getSectionTitle(context, 'Recent Uses'),
              const Divider(),
              const Padding(padding: EdgeInsets.all(5)),
              FutureBuilder<List<WorkoutExercise>?>(
                future: workoutExercises,
                builder: (context, weSnapshot) {
                  if (!weSnapshot.hasData) {
                    return const Center(
                      child: Text('Loading...'),
                    );
                  }

                  if (weSnapshot.data == null || weSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No recent uses of this exercise.'),
                      ),
                    );
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: getRecentUsesWidget(
                            weSnapshot.data!,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
