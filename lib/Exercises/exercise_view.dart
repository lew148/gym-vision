import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/user_exercise_details.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/helpers/user_exercise_details_helper.dart';
import 'package:gymvision/exercises/exercise_recent_uses_view.dart';
import 'package:gymvision/globals.dart';

import '../db/helpers/exercises_helper.dart';
import '../enums.dart';
import '../shared/ui_helper.dart';

class ExerciseView extends StatefulWidget {
  final int exerciseId;

  const ExerciseView({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  late Future<Exercise?> _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = ExercisesHelper.getExercise(
      id: widget.exerciseId,
      includeUserDetails: true,
      includeRecentUses: true,
    );
  }

  reloadState() => setState(() {});

  Widget getNotesDisplay(Exercise exercise) => Column(children: [
        getSectionTitle(context, 'Notes'),
        const Divider(),
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
                    padding: const EdgeInsets.all(10),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(exercise.userExerciseDetails?.notes == null
                                  ? '-'
                                  : exercise.userExerciseDetails!.notes!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]);

  Widget getExerciseViewWidget(Exercise exercise) =>
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        getExercisePropDisplay("Type", exercise.exerciseType.displayName),
        getExercisePropDisplay("Muscle Group", exercise.muscleGroup.displayName),
        getExercisePropDisplay("Split", exercise.split.displayName),
        getExercisePropDisplay("Equipment", exercise.equipment.displayName),
        getNotesDisplay(exercise),
      ]);

  void openNotesForm(Exercise exercise) {
    var controller = TextEditingController(text: exercise.userExerciseDetails?.notes);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Edit Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                                    if (exercise.userExerciseDetails?.notes == newValue) return;
                                    exercise.userExerciseDetails!.notes = newValue;
                                    await UserExerciseDetailsHelper.updateUserExerciseDetails(
                                        exercise.userExerciseDetails!);
                                  } catch (ex) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('Failed to edit Notes')));
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

  Widget getExerciseProps(Exercise exercise) => Row();

  Widget getExercisePropDisplay(String label, String value) => Column(children: [
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              getPropDisplay(context, value),
            ],
          ),
        ),
        const Divider(),
      ]);

  List<Widget> getRecentUsesWidget(List<WorkoutSet> workoutSets) {
    workoutSets.removeWhere((ws) => dateIsInFuture(ws.workout!.date));
    workoutSets.sort(((a, b) => b.workout!.date.compareTo(a.workout!.date)));

    final Map<int, List<WorkoutSet>> groupedWorkoutExercises = groupBy<WorkoutSet, int>(
      workoutSets,
      (x) => x.workoutId,
    );

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ExerciseRecentUsesView(
            workoutSets: value,
          ),
        ),
      );
    });

    return weWidgets;
  }

  Widget getPrWidget(WorkoutSet pr) => Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Card(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      pr.workout!.getDateAndTimeString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pr.hasWeight()
                            ? [
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 15,
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                Text(pr.getWeightDisplay()),
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
                        Text(pr.getRepsDisplayString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );

  List<Widget> getDetailsSections(UserExerciseDetails details) => [
        getSectionTitle(context, 'PR'),
        const Divider(),
        details.pr == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('No PR set.'),
                ),
              )
            : Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: getPrWidget(details.pr!),
              ),
        getSectionTitle(context, 'Recent Uses'),
        const Divider(),
        details.recentUses == null || details.recentUses!.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent uses of this exercise.'),
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      children: getRecentUsesWidget(
                        details.recentUses!,
                      ),
                    ),
                  ),
                ),
              ),
      ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise?>(
      future: _exercise,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Loading...'),
            ),
          );
        }

        var exercise = snapshot.data!;
        var details = exercise.userExerciseDetails;

        return Scaffold(
          appBar: AppBar(
            title: Text(exercise.name),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: getExerciseViewWidget(snapshot.data!),
              ),
              if (details != null) ...getDetailsSections(details),
            ],
          ),
        );
      },
    );
  }
}
