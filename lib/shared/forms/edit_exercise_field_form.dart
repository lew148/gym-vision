import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';
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

    Widget getField() {
      switch (widget.editableField) {
        case ExerciseEditableField.name:
          return CustomFormFields.stringField(
            controller: fieldController,
            label: widget.label,
            canBeBlank: false,
            autofocus: true,
          );
        case ExerciseEditableField.weight:
        case ExerciseEditableField.max:
          return CustomFormFields.weightField(
            controller: fieldController,
            label: widget.label,
            isSingle: widget.exercise.isSingle,
            autofocus: true,
          );
        case ExerciseEditableField.reps:
          return CustomFormFields.intField(
            controller: fieldController,
            label: widget.label,
            autofocus: true,
          );
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
                final newValue = double.parse(getNumberStringOrDefault(fieldController.text));

                if (widget.exercise.weight == newValue) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.weight = newValue;
                break;
              }
            case ExerciseEditableField.max:
              {
                final newValue = double.parse(getNumberStringOrDefault(fieldController.text));

                if (widget.exercise.max == newValue) {
                  doUpdate = false;
                  break;
                }

                widget.exercise.max = newValue;
                break;
              }
            case ExerciseEditableField.reps:
              {
                final newValue = int.tryParse(getNumberStringOrDefault(fieldController.text));

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
            const SnackBar(content: Text('Failed to edit exercise')),
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
