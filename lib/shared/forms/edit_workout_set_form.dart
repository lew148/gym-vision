import 'package:flutter/material.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';

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

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: widget.workoutSet.getWeightAsString());
    repsController = TextEditingController(text: widget.workoutSet.getRepsAsString());
  }

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      bool changeMade = false;

      final newWeight = double.parse(getNumberStringOrDefault(weightController.text));
      final newReps = int.parse(getNumberStringOrDefault(repsController.text));

      if (widget.workoutSet.weight != newWeight) {
        widget.workoutSet.weight = newWeight;
        changeMade = true;
      }

      if (widget.workoutSet.reps != newReps) {
        widget.workoutSet.reps = newReps;
        changeMade = true;
      }

      if (!changeMade) return;

      try {
        await WorkoutSetsHelper.updateWorkoutSet(widget.workoutSet);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to remove Set from workout: ${ex.toString()}')));
    }

    widget.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Edit Workout Set',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Divider(),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormFields.weightField(
                  controller: weightController,
                  label: 'Weight',
                  isSingle: !widget.workoutSet.exercise!.isDouble,
                  last: widget.workoutSet.exercise!.userExerciseDetails?.getLastAsString(),
                  max: widget.workoutSet.exercise!.userExerciseDetails?.getPRAsString(),
                ),
                CustomFormFields.intField(
                  controller: repsController,
                  label: 'Reps',
                  selectableValues: [1, 8, 12],
                ),
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
                    ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text('Save'),
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
