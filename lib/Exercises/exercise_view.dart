import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';

import '../db/helpers/exercises_helper.dart';
import '../enums.dart';
import 'edit_exercise_field_form.dart';

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

  Widget getExerciseViewWidget(Exercise exercise) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: getValueDisplay(
              'Weight',
              exercise.getWeightString(),
              () => openEditExerciseFieldForm(
                exercise,
                ExerciseEditableField.weight,
                'Weight',
                exercise.getWeightAsString(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: getValueDisplay(
              'Max',
              exercise.getMaxString(),
              () => openEditExerciseFieldForm(
                exercise,
                ExerciseEditableField.max,
                'Max',
                exercise.getMaxAsString(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: getValueDisplay(
              'Reps',
              exercise.reps.toString(),
              () => openEditExerciseFieldForm(
                exercise,
                ExerciseEditableField.reps,
                'Reps',
                exercise.reps.toString(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: getValueDisplay(
              'Is Single',
              exercise.getIsSingleString(),
              () async {
                exercise.isSingle = !exercise.isSingle;
                ExercisesHelper().updateExercise(exercise);
                reloadState();
              },
            ),
          ),
        ],
      );

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

  Widget getValueDisplay(String label, String value, Function() onTap) => Card(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    const Padding(padding: EdgeInsets.all(5)),
                    Text(
                      value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
                const Icon(
                  Icons.edit,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Future<Exercise> exercise =
        ExercisesHelper().getExercise(widget.exerciseId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: FutureBuilder<Exercise>(
        future: exercise,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: getExerciseViewWidget(snapshot.data!),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
