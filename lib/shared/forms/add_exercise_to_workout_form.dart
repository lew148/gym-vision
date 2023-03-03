import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout.dart';

import '../../db/classes/exercise.dart';
import '../../db/helpers/workouts_helper.dart';
import '../../globals.dart';
import 'fields/custom_form_fields.dart';
import 'fields/exercise_picker.dart';
import 'fields/workout_picker.dart';

class AddExerciseToWorkoutForm extends StatefulWidget {
  final int? workoutId;
  final int? exerciseId;
  final List<int>? excludeExerciseIds;
  final List<int>? categoryIds;
  final bool disableWorkoutPicker;
  final bool disableExercisePicker;
  final Function reloadState;
  final int initialSets;

  const AddExerciseToWorkoutForm({
    Key? key,
    this.workoutId,
    this.exerciseId,
    this.excludeExerciseIds,
    this.categoryIds,
    this.disableWorkoutPicker = false,
    this.disableExercisePicker = false,
    this.initialSets = 3,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddExerciseToWorkoutForm> createState() => _AddExerciseToWorkoutFormState();
}

class _AddExerciseToWorkoutFormState extends State<AddExerciseToWorkoutForm> {
  Workout? selectedWorkout;
  Exercise? selectedExercise;

  final formKey = GlobalKey<FormState>();
  late TextEditingController setsController;
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setsController = TextEditingController(text: widget.initialSets.toString());
  }

  void setWeightAndRepControllers(Exercise? ex) {
    if (ex != null) {
      weightController.text = ex.getWeightAsString() ?? '';
      repsController.text = ex.reps.toString();
    } else {
      weightController.text = '';
      repsController.text = '';
    }
  }

  List<Widget> getExerciseFields(Exercise ex) => [
        CustomFormFields.weightField(
          controller: weightController,
          label: 'Weight',
          isSingle: ex.isSingle,
          defaultWeight: ex.getWeightAsString(),
          max: ex.max == 0 ? ex.getWeightAsString() : ex.getMaxAsString(),
        ),
        CustomFormFields.intField(
          controller: repsController,
          label: 'Reps',
          selectableValues: [1, 8, 12],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    void onSubmit() async {
      if (selectedExercise == null && widget.exerciseId == null) return; // todo: show error
      if (selectedWorkout == null && widget.workoutId == null) return; // todo: show error

      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          await WorkoutsHelper.addExerciseToWorkout(
            exerciseId: selectedExercise?.id ?? widget.exerciseId!,
            workoutId: selectedWorkout?.id ?? widget.workoutId!,
            weight: double.parse(getNumberStringOrDefault(weightController.text)),
            reps: int.parse(getNumberStringOrDefault(repsController.text)),
            sets: int.parse(getNumberStringOrDefault(setsController.text)),
          );
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add Exercise to workout')),
          );
        }

        widget.reloadState();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: IntrinsicHeight(
          child: Column(
            children: [
              const Text(
                'Add Exercise To Workout',
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
              if (!widget.disableWorkoutPicker) const Padding(padding: EdgeInsets.all(5)),
              ExercisePicker(
                exerciseId: widget.exerciseId,
                exercise: selectedExercise,
                excludeIds: widget.excludeExerciseIds,
                categoryIds: widget.categoryIds,
                disabled: widget.disableExercisePicker,
                autoOpen: widget.disableWorkoutPicker,
                setExercise: (newExercise) => setState(() {
                  selectedExercise = newExercise;
                  setWeightAndRepControllers(newExercise);
                }),
              ),
              if (!widget.disableExercisePicker) const Padding(padding: EdgeInsets.all(5)),
              if (selectedExercise != null) ...getExerciseFields(selectedExercise!),
              CustomFormFields.intField(
                controller: setsController,
                label: 'Sets',
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
      ),
    );
  }
}
