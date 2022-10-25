import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/globals.dart';

import '../db/classes/workout_exercise.dart';

class EditWorkoutExerciseForm extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final void Function() reloadState;

  const EditWorkoutExerciseForm({
    Key? key,
    required this.workoutExercise,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<EditWorkoutExerciseForm> createState() =>
      _EditWorkoutExerciseFormState();
}

class _EditWorkoutExerciseFormState extends State<EditWorkoutExerciseForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController weightController;
  late final TextEditingController repsController;
  late final TextEditingController setsController;

  @override
  void initState() {
    super.initState();
    weightController =
        TextEditingController(text: widget.workoutExercise.getWeightAsString());
    repsController =
        TextEditingController(text: widget.workoutExercise.reps.toString());
    setsController =
        TextEditingController(text: widget.workoutExercise.sets.toString());
  }

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      bool changeMade = false;

      final newWeight =
          double.parse(getNumberStringOrDefault(weightController.text));
      final newReps = int.parse(getNumberStringOrDefault(repsController.text));
      final newSets = int.parse(getNumberStringOrDefault(setsController.text));

      if (widget.workoutExercise.weight != newWeight) {
        widget.workoutExercise.weight = newWeight;
        changeMade = true;
      }

      if (widget.workoutExercise.reps != newReps) {
        widget.workoutExercise.reps = newReps;
        changeMade = true;
      }

      if (widget.workoutExercise.sets != newSets) {
        widget.workoutExercise.sets = newSets;
        changeMade = true;
      }

      if (!changeMade) return;

      try {
        await WorkoutsHelper.updateWorkoutExercise(widget.workoutExercise);
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to edit Workout Exercise: $ex'),
          ),
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
            'Edit Workout Exercise',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    suffix: const Text('kg'),
                    prefix: Text(widget.workoutExercise.exercise!.isSingle ? '' : '2 x '),
                  ),
                ),
                TextFormField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'reps',
                  ),
                ),
                TextFormField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'sets',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
