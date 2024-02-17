import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/classes/user_exercise_details.dart';
import 'package:gymvision/db/classes/workout_set.dart';
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

  Widget getNotesDisplay(UserExerciseDetails details) => Column(children: [
        getSectionTitle(context, 'Notes'),
        const Divider(thickness: 0.25),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => openNotesForm(details),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(10),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(details.notes == null ? '-' : details.notes!),
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

  Widget getExerciseViewWidget(Exercise exercise) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 5),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Wrap(children: [
              if (exercise.exerciseType != ExerciseType.other)
                getPropDisplay(context, exercise.exerciseType.displayName),
              if (exercise.muscleGroup != MuscleGroup.other) getPropDisplay(context, exercise.muscleGroup.displayName),
            ]),
            Wrap(children: [
              if (exercise.split != ExerciseSplit.other) getPropDisplay(context, exercise.split.displayName),
              if (exercise.equipment != ExerciseEquipment.other)
                getPropDisplay(context, exercise.equipment.displayName),
            ]),
          ],
        ),
      );

  void openNotesForm(UserExerciseDetails details) {
    var controller = TextEditingController(text: details.notes);

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
                                    if (details.notes == newValue) return;
                                    details.notes = newValue;
                                    // await UserExerciseDetailsHelper.updateUserExerciseDetails(details);
                                  } catch (ex) {
                                    if (!mounted) return;

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

  List<Widget> getRecentUsesWidget(List<WorkoutSet> workoutSets) {
    workoutSets.removeWhere((ws) => dateIsInFuture(ws.workout!.date));
    workoutSets.sort(((a, b) => b.workout!.date.compareTo(a.workout!.date)));

    final Map<int, List<WorkoutSet>> groupedWorkoutExercises =
        groupBy<WorkoutSet, int>(workoutSets, (x) => x.workoutId);

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ExerciseRecentUsesView(workoutSets: value),
        ),
      );
    });

    return weWidgets;
  }

  List<Widget> getPrSection(WorkoutSet? pr) => [
        getSectionTitle(context, 'PR'),
        const Divider(thickness: 0.25),
        pr == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('No PR set.'),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Text(pr.workout!.getDateStr()),
                        Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 15,
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  pr.getWeightDisplay(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                              Text(pr.getRepsDisplay()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ];

  List<Widget> getDetailsSections(Exercise exercise, UserExerciseDetails details) => [
        if (exercise.exerciseType == ExerciseType.weight) ...getPrSection(details.pr),
        // getSectionTitle(context, 'Notes'),
        // getNotesDisplay(details),
        getSectionTitle(context, 'Recent Uses'),
        const Divider(thickness: 0.25),
        details.recentUses == null || details.recentUses!.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('No recent uses of this exercise.'),
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: getRecentUsesWidget(details.recentUses!),
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
          appBar: AppBar(title: Text(exercise.name)),
          body: Column(
            children: [
              getExerciseViewWidget(snapshot.data!),
              if (details != null) ...getDetailsSections(exercise, details),
            ],
          ),
        );
      },
    );
  }
}
