import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/enums.dart';

import '../db/helpers/exercises_helper.dart';
import 'add_exercise_form.dart';
import 'add_exercise_to_workouts_form.dart';
import 'edit_exercise_field_form.dart';
import 'exercise_view.dart';

class CategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryView(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  reloadState() => setState(() {});

  Widget getExerciseWidget(Exercise exercise) => Row(
        children: [
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => ExerciseView(
                          exerciseId: exercise.id!,
                          exerciseName: exercise.name,
                        ),
                      ),
                    )
                    .then((value) => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          if (exercise.hasWeight())
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 15,
                                    color: Theme.of(context).colorScheme.shadow,
                                  ),
                                  const Padding(padding: EdgeInsets.all(5)),
                                  Text(
                                    exercise.getNumberedWeightString(
                                        showNone: false),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 15,
                                color: Theme.of(context).colorScheme.shadow,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(
                                '${exercise.reps} reps',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.shadow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => showMoreMenu(exercise),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void onAddExerciseToWorkoutTap(int exerciseId) {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddExerciseToWorkoutsForm(exerciseId: exerciseId),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

      WorkoutsHelper.addExerciseToWorkout(0, exerciseId);
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add exercise to workout: $ex')),
      );
    }
  }

  void onEditNameTap(Exercise exercise) {
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
              reloadState: reloadState,
              currentValue: exercise.name,
              editableField: ExerciseEditableField.name,
              label: 'Name',
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    );
  }

  void showDeleteExerciseConfirm(int exerciseId) {
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
          ExercisesHelper().deleteExercise(exerciseId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete exercise: ${ex.toString()}')),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete Exercise?"),
      content:
          const Text("Are you sure you would like to delete this exercise?"),
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

  void openAddExerciseForm() => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddExerciseForm(
                categoryId: widget.categoryId,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  void showMoreMenu(Exercise exercise) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onAddExerciseToWorkoutTap(exercise.id!);
                },
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Add to workout',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                  onEditNameTap(exercise);
                },
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Name',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                  showDeleteExerciseConfirm(exercise.id!);
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Delete',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
    final Future<List<Exercise>> exercises =
        ExercisesHelper().getExercisesForCategory(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => openAddExerciseForm(),
                child: const Icon(Icons.add),
              )),
        ],
      ),
      body: FutureBuilder<List<Exercise>>(
        future: exercises,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Exercises here :(',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: Column(
                children:
                    snapshot.data!.map((c) => getExerciseWidget(c)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
