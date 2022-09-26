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

  Widget getExerciseViewWidget(Exercise exercise) => Column(
        children: [
          getValueDisplay(
            'Weight',
            exercise.getWeightString(),
            () => openEditExerciseFieldForm(
              exercise,
              ExerciseEditableField.weight,
              'Weight',
              exercise.getWeightAsString(),
            ),
          ),
          getValueDisplay(
            'Max',
            exercise.getMaxString(),
            () => openEditExerciseFieldForm(
              exercise,
              ExerciseEditableField.max,
              'Max',
              exercise.getMaxAsString(),
            ),
          ),
          getValueDisplay(
            'Reps',
            exercise.reps.toString(),
            () => openEditExerciseFieldForm(
              exercise,
              ExerciseEditableField.reps,
              'Reps',
              exercise.reps.toString(),
            ),
          ),
          getValueDisplay(
            'Is Single',
            exercise.getIsSingleString(),
            () async {
              exercise.isSingle = !exercise.isSingle;
              ExercisesHelper().updateExercise(exercise);
              reloadState();
            },
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

  Widget getValueDisplay(String label, String value, Function() onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Colors.grey[600]!,
              ),
            ),
            color: Colors.grey[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
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

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: getExerciseViewWidget(snapshot.data!),
          );
        },
      ),
    );
  }
}
