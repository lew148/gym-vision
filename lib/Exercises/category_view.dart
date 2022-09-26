import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';

import '../db/helpers/exercises_helper.dart';
import 'add_exercise_form.dart';
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
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Colors.grey[600]!,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey[100],
              ),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                onLongPress: () => showDeleteExerciseConfirm(exercise.id!),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        exercise.getNumberedWeightString(showNone: false),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${exercise.reps} reps',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  void showDeleteExerciseConfirm(int id) {
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
          ExercisesHelper().deleteExercise(id);
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
