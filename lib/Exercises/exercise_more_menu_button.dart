import 'package:flutter/material.dart';

import '../db/classes/exercise.dart';
import '../db/helpers/exercises_helper.dart';
import '../enums.dart';
import '../shared/forms/add_exercise_to_workouts_form.dart';
import '../shared/forms/edit_exercise_field_form.dart';

class ExerciseMoreMenuButton extends StatefulWidget {
  final Exercise exercise;
  final Function() reloadState;
  final Function()? onDelete;

  const ExerciseMoreMenuButton({
    super.key,
    required this.exercise,
    required this.reloadState,
    this.onDelete,
  });

  @override
  State<ExerciseMoreMenuButton> createState() => _ExerciseMoreMenuButtonState();
}

class _ExerciseMoreMenuButtonState extends State<ExerciseMoreMenuButton> {
  void showMoreMenu(Exercise exercise) {
    void onAddExerciseToWorkoutTap(Exercise exercise) => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddExerciseToWorkoutsForm(exercise: exercise),
              ),
            ],
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
        );

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
                reloadState: widget.reloadState,
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
            await ExercisesHelper.deleteExercise(exerciseId);
          } catch (ex) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete exercise: ${ex.toString()}'),
              ),
            );
          }

          if (widget.onDelete == null) {
            widget.reloadState();
          } else {
            widget.onDelete!();
          }
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
                  onAddExerciseToWorkoutTap(exercise);
                },
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Add to workout',
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
                  onEditNameTap(exercise);
                },
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Name',
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
                  showDeleteExerciseConfirm(exercise.id!);
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Delete',
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

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => showMoreMenu(widget.exercise),
    );
  }
}
