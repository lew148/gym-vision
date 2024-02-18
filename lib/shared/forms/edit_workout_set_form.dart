import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';
import 'package:gymvision/shared/ui_helper.dart';

import '../../db/classes/workout_set.dart';
import '../../db/helpers/workout_sets_helper.dart';

class EditWorkoutExerciseForm extends StatefulWidget {
  final WorkoutSet workoutSet;
  final void Function() reloadState;

  const EditWorkoutExerciseForm({
    Key? key,
    required this.workoutSet,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<EditWorkoutExerciseForm> createState() => _EditWorkoutExerciseFormState();
}

class _EditWorkoutExerciseFormState extends State<EditWorkoutExerciseForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController weightController;
  late final TextEditingController repsController;
  late final TextEditingController distanceController;
  late final TextEditingController calsBurnedController;
  late Duration duration;

  String blankStringIfZero(String s) => s == '0' ? '' : s;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: blankStringIfZero(truncateDouble(widget.workoutSet.weight)));
    repsController = TextEditingController(text: blankStringIfZero(widget.workoutSet.reps.toString()));
    distanceController = TextEditingController(text: blankStringIfZero(truncateDouble(widget.workoutSet.distance)));
    calsBurnedController = TextEditingController(text: blankStringIfZero(widget.workoutSet.calsBurned.toString()));
    duration = widget.workoutSet.time ?? const Duration();
  }

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      bool hasChanges = false;

      final newWeight = double.parse(getNumberString(weightController.text));
      final newReps = int.parse(getNumberString(repsController.text));
      final newDistance = double.parse(getNumberString(distanceController.text));
      final newCalsBurned = int.parse(getNumberString(calsBurnedController.text));
      final newDuration = duration;

      final set = widget.workoutSet;

      if (set.weight != newWeight) {
        set.weight = newWeight;
        hasChanges = true;
      }

      if (set.reps != newReps) {
        set.reps = newReps;
        hasChanges = true;
      }

      if (set.distance != newDistance) {
        set.distance = newDistance;
        hasChanges = true;
      }

      if (set.calsBurned != newCalsBurned) {
        set.calsBurned = newCalsBurned;
        hasChanges = true;
      }

      if (set.time != newDuration) {
        set.time = newDuration;
        hasChanges = true;
      }

      if (!hasChanges) return;

      try {
        await WorkoutSetsHelper.updateWorkoutSet(set);
      } catch (ex) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit Workout Set')));
      }

      widget.reloadState();
    }
  }

  void onDeleteButtonTap(int id) async {
    Navigator.pop(context);
    try {
      await WorkoutSetsHelper.removeSet(id);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove Set from workout: ${ex.toString()}')),
      );
    }

    widget.reloadState();
  }

  List<Widget> getWeightFields(Exercise ex) => [
        CustomFormFields.doubleField(
          controller: weightController,
          label: 'Weight',
          isDouble: ex.isDouble,
          unit: 'kg',
          last: ex.userExerciseDetails?.getLastAsString(),
          max: ex.userExerciseDetails?.getPRAsString(),
        ),
        CustomFormFields.intField(
          controller: repsController,
          label: 'Reps',
          selectableValues: [1, 8, 10, 12],
        ),
      ];

  List<Widget> getCardioFields(Exercise ex) => [
        CustomFormFields.durationField(
          'Time',
          context,
          duration,
          (Duration newDuration) => setState(() => duration = newDuration),
        ),
        CustomFormFields.doubleField(
          controller: distanceController,
          label: 'Distance',
          isDouble: false,
          unit: 'km',
        ),
        CustomFormFields.intField(
          controller: calsBurnedController,
          label: 'Cals Burned',
          unit: 'kcal',
          showNone: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final exercise = widget.workoutSet.exercise!;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Edit Workout Set',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Divider(thickness: 0.25),
          Form(
            key: formKey,
            child: Column(
              children: [
                if (exercise.exerciseType == ExerciseType.weight) ...getWeightFields(exercise),
                if (exercise.exerciseType == ExerciseType.cardio) ...getCardioFields(exercise),
                if (exercise.exerciseType == ExerciseType.stretch) ...getWeightFields(exercise),
                const Padding(padding: EdgeInsets.only(top: 20.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      onPressed: () => onDeleteButtonTap(widget.workoutSet.id!),
                    ),
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: onSubmit,
                        text: 'Save',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
