import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import '../db/classes/exercise.dart';
import '../globals.dart';

class AddExerciseForm extends StatefulWidget {
  final int categoryId;
  final void Function() reloadState;

  const AddExerciseForm({
    Key? key,
    required this.categoryId,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController(text: '3');
  bool isSingleValue = false;

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        await ExercisesHelper().insertExercise(Exercise(
          categoryId: widget.categoryId,
          name: nameController.text,
          weight: double.parse(getNumberOrDefault(weightController.text)),
          max: 0, // to set in edit
          reps: int.parse(getNumberOrDefault(repsController.text)),
          isSingle: isSingleValue,
        ));
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add exercise: $ex')),
        );
      }

      widget.reloadState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Exercise',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Weight', suffix: Text('kg')),
                ),
                TextFormField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                  ),
                ),
                FormField(
                  builder: (field) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Is Single'),
                    value: isSingleValue,
                    onChanged: ((value) =>
                        {setState(() => isSingleValue = value!)}),
                  ),
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
