import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout.dart';

import '../../db/classes/exercise.dart';
import 'fields/exercise_picker.dart';
import 'fields/workout_picker.dart';

class AddExerciseToWorkoutForm extends StatefulWidget {
  final int? workoutId;
  final int? exerciseId;
  final bool disableWorkoutPicker;
  final bool disableExercisePicker;
  final Function reloadState;

  const AddExerciseToWorkoutForm({
    Key? key,
    this.workoutId,
    this.exerciseId,
    this.disableWorkoutPicker = false,
    this.disableExercisePicker = false,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddExerciseToWorkoutForm> createState() =>
      _AddExerciseToWorkoutFormState();
}

class _AddExerciseToWorkoutFormState extends State<AddExerciseToWorkoutForm> {
  Workout? selectedWorkout;
  Exercise? selectedExercise;

  final formKey = GlobalKey<FormState>();
  final setsController = TextEditingController(text: '3');
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  void setWeightAndRepControllers(Exercise ex) {
    weightController.text = ex.getWeightAsString();
    repsController.text = ex.reps.toString();
  }

  List<Widget> getExerciseFields(Exercise ex) => [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  prefix: ex.isSingle ? const Text('') : const Text('2 x '),
                  suffix: const Text('kg'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
              child: OutlinedButton(
                onPressed: () => setState(() {
                  weightController.text = ex.getWeightAsString();
                }),
                child: const Text('Default'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: OutlinedButton(
                onPressed: () => setState(() {
                  weightController.text = ex.max == 0
                      ? ex.getWeightAsString()
                      : ex.getMaxAsString();
                }),
                child: const Text('Max'),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: repsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Reps',
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    void onSubmit() async {
      if (selectedExercise == null || selectedWorkout == null) {
        return; // todo: show error
      }

      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          // await WorkoutsHelper.addExerciseToWorkouts(
          //   exerciseId: exercise!.id!,
          //   workoutId: workout!.id,
          //   weight:
          //       double.parse(getNumberStringOrDefault(weightController.text)),
          //   reps: int.parse(getNumberStringOrDefault(repsController.text)),
          //   sets: int.parse(getNumberStringOrDefault(setsController.text)),
          // );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully Added exercise to workout!'),
              ),
            );
          }
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add exercise to workout: $ex',
              ),
            ),
          );
        }

        widget.reloadState();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text(
              'Add Exercise To Workouts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Divider(),
            WorkoutPicker(
              workoutId: widget.workoutId,
              workout: selectedWorkout,
              disabled: widget.disableWorkoutPicker,
              setWorkout: (newWorkout) => setState(() {
                selectedWorkout = newWorkout;
              }),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            ExercisePicker(
              exerciseId: widget.exerciseId,
              setExercise: (newExercise) => setState(() {
                selectedExercise = newExercise;
                setWeightAndRepControllers(newExercise);
              }),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            if (selectedExercise != null)
              ...getExerciseFields(selectedExercise!),
            TextFormField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
