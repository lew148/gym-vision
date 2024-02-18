import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/ui_helper.dart';
import '../../db/classes/exercise.dart';
import '../../db/helpers/workout_sets_helper.dart';
import '../../globals.dart';
import 'fields/custom_form_fields.dart';
import 'fields/exercise_picker.dart';

class AddSetToWorkoutForm extends StatefulWidget {
  final int? workoutId;
  final int? exerciseId;
  final List<int>? categoryShellIds;
  final List<int>? existingExerciseIds;
  final Function reloadState;

  const AddSetToWorkoutForm({
    Key? key,
    this.workoutId,
    this.exerciseId,
    this.categoryShellIds,
    this.existingExerciseIds,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddSetToWorkoutForm> createState() => _AddSetToWorkoutFormState();
}

class _AddSetToWorkoutFormState extends State<AddSetToWorkoutForm> {
  Exercise? selectedExercise;

  final formKey = GlobalKey<FormState>();
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  Duration duration = const Duration();
  TextEditingController distanceController = TextEditingController();
  TextEditingController calsBurnedController = TextEditingController();

  void resetWeightAndReps() {
    weightController.text = '';
    repsController.text = '';
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
    void onSubmit({bool addThree = false, Exercise? overrideExercise}) async {
      final subject = overrideExercise ?? selectedExercise;
      if (subject == null && widget.exerciseId == null) return; // todo: show error

      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          for (int i = 0; i < (addThree ? 3 : 1); i++) {
            await WorkoutSetsHelper.addSetToWorkout(
              WorkoutSet(
                exerciseId: subject?.id ?? widget.exerciseId!,
                workoutId: widget.workoutId!,
                weight: double.parse(getNumberString(weightController.text)),
                reps: int.parse(getNumberString(repsController.text)),
                distance: double.parse(getNumberString(distanceController.text)),
                calsBurned: int.parse(getNumberString(calsBurnedController.text)),
                time: duration,
              ),
            );
          }
        } catch (ex) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add set(s) to workout')));
        }

        widget.reloadState();
      }
    }

    void onQuickAdd(Exercise exercise) async {
      onSubmit(overrideExercise: exercise);
      Navigator.of(context).pop();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: IntrinsicHeight(
          child: Column(
            children: [
              getSectionTitle(context, 'Add Set'),
              const Divider(thickness: 0.25),
              ExercisePicker(
                exerciseId: widget.exerciseId,
                exercise: selectedExercise,
                existingExerciseIds: widget.existingExerciseIds,
                categoryShellIds: widget.categoryShellIds,
                autoOpen: true,
                onQuickAdd: onQuickAdd,
                setExercise: (newExercise) => setState(() {
                  selectedExercise = newExercise;
                  resetWeightAndReps();
                }),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              if (selectedExercise != null && selectedExercise!.exerciseType == ExerciseType.weight)
                ...getWeightFields(selectedExercise!),
              if (selectedExercise != null && selectedExercise!.exerciseType == ExerciseType.cardio)
                ...getCardioFields(selectedExercise!),
              if (selectedExercise != null && selectedExercise!.exerciseType == ExerciseType.stretch)
                ...getWeightFields(selectedExercise!),
              if (selectedExercise != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.exerciseId == null
                          ? getElevatedPrimaryButton(
                              context,
                              ActionButton(onTap: () => onSubmit(addThree: true), text: 'Add 3'),
                            )
                          : const SizedBox.shrink(),
                      getElevatedPrimaryButton(context, ActionButton(onTap: onSubmit, text: 'Add')),
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
