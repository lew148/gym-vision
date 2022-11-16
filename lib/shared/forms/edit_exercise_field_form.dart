import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/enums.dart';
import '../../db/classes/exercise.dart';
import '../../globals.dart';

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
    final fieldController = TextEditingController(
      text: widget.currentValue == '0' ? null : widget.currentValue,
    );

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
      bool doUpdate = true;

      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          switch (widget.editableField) {
            case ExerciseEditableField.name:
              {
                if (widget.exercise.name == fieldController.text) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.name = fieldController.text;
                break;
              }
            case ExerciseEditableField.weight:
              {
                final newValue = double.parse(
                    getNumberStringOrDefault(fieldController.text));

                if (widget.exercise.weight == newValue) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.weight = newValue;
                break;
              }
            case ExerciseEditableField.max:
              {
                final newValue = double.parse(
                    getNumberStringOrDefault(fieldController.text));

                if (widget.exercise.max == newValue) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.max = newValue;
                break;
              }
            case ExerciseEditableField.reps:
              {
                final newValue = int.tryParse(
                    getNumberStringOrDefault(fieldController.text));

                if (newValue == null) {
                  throw Exception('Inputted reps is not a valid integer');
                }

                if (widget.exercise.reps == newValue) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.reps = newValue;
                break;
              }
          }

          if (!doUpdate) return;
          await ExercisesHelper.updateExercise(widget.exercise);
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
                Row(
                  children: [
                    Expanded(
                      child: getField(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 5, 0),
                      child: OutlinedButton(
                        onPressed: () => fieldController.text = '',
                        child: const Text('None'),
                      ),
                    ),
                  ],
                ),
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
