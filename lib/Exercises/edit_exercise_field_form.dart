import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/enums.dart';
import '../db/classes/exercise.dart';
import '../globals.dart';

class EditExerciseFieldForm extends StatefulWidget {
  final Exercise exercise;
  final ExerciseEditableField editableField;
  final String label;
  final String currentValue;
  final void Function() reloadState;

  const EditExerciseFieldForm({
    Key? key,
    required this.exercise,
    required this.editableField,
    required this.label,
    required this.currentValue,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<EditExerciseFieldForm> createState() => _EditExerciseFieldFormState();
}

class _EditExerciseFieldFormState extends State<EditExerciseFieldForm> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fieldController = TextEditingController(text: widget.currentValue);

    Widget textField() => TextFormField(
          controller: fieldController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: widget.label,
          ),
        );

    Widget doubleField() => TextFormField(
          controller: fieldController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.label,
            suffix: const Text('kg'),
          ),
        );

    Widget getField() {
      switch (widget.editableField) {
        case ExerciseEditableField.name:
          return textField();
        case ExerciseEditableField.weight:
        case ExerciseEditableField.max:
        case ExerciseEditableField.reps:
          return doubleField();
      }
    }

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          switch (widget.editableField) {
            case ExerciseEditableField.name:
              {
                widget.exercise.name = fieldController.text;
                break;
              }
            case ExerciseEditableField.weight:
              {
                widget.exercise.weight =
                    double.parse(getNumberOrDefault(fieldController.text));
                break;
              }
            case ExerciseEditableField.max:
              {
                widget.exercise.max =
                    double.parse(getNumberOrDefault(fieldController.text));
                break;
              }
            case ExerciseEditableField.reps:
              {
                widget.exercise.reps =
                    int.parse(getNumberOrDefault(fieldController.text));
                break;
              }
          }

          await ExercisesHelper().updateExercise(widget.exercise);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to edit exercise: $ex')),
          );
        }

        widget.reloadState();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Edit Exercise',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                getField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
