import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/pages/forms/fields/custom_form_fields.dart';
import 'package:gymvision/pages/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';

class EditWorkoutSetForm extends StatefulWidget {
  final WorkoutSet workoutSet;
  final void Function() reloadState;
  final Exercise? exerciseWithDetails;

  const EditWorkoutSetForm({
    super.key,
    required this.workoutSet,
    required this.reloadState,
    this.exerciseWithDetails,
  });

  @override
  State<EditWorkoutSetForm> createState() => _EditWorkoutSetFormState();
}

class _EditWorkoutSetFormState extends State<EditWorkoutSetForm> {
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
        await WorkoutSetModel.updateWorkoutSet(set);
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
      await WorkoutSetModel.removeSet(id);
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
          unit: 'kg',
          last: ex.exerciseDetails?.getLastAsString(),
          max: ex.exerciseDetails?.getPRAsString(),
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
          unit: 'km',
        ),
        CustomFormFields.intField(
          controller: calsBurnedController,
          label: 'Cals Burned',
          unit: 'kcal',
          showNone: true,
        ),
      ];

  void onCopySetButtonTap() async {
    try {
      HapticFeedback.heavyImpact();
      await WorkoutSetModel.addSetToWorkout(
        WorkoutSet(
          workoutExerciseId: widget.workoutSet.workoutExerciseId,
          weight: widget.workoutSet.weight,
          time: widget.workoutSet.time,
          distance: widget.workoutSet.distance,
          calsBurned: widget.workoutSet.calsBurned,
          reps: widget.workoutSet.reps,
          done: false,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed add set to workout: ${ex.toString()}')));
    }

    widget.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exerciseWithDetails;

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
                if (exercise != null && exercise.type == ExerciseType.strength) ...getWeightFields(exercise),
                if (exercise != null && exercise.type == ExerciseType.cardio) ...getCardioFields(exercise),
                // if (exercise.exerciseType == ExerciseType.stretch) ...getWeightFields(exercise),
                const Padding(padding: EdgeInsets.only(top: 20.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        onPressed: () => onDeleteButtonTap(widget.workoutSet.id!),
                      ),
                      CommonUi.getPrimaryButton(
                        ButtonDetails(
                          icon: Icons.copy_rounded,
                          onTap: () => onCopySetButtonTap(),
                        ),
                      ),
                    ]),
                    CommonUi.getElevatedPrimaryButton(
                      context,
                      ButtonDetails(
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
