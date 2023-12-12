import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';
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
  final Function reloadState;

  const AddSetToWorkoutForm({
    Key? key,
    this.workoutId,
    this.exerciseId,
    this.categoryShellIds,
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

  void resetWeightAndReps() {
    weightController.text = '';
    repsController.text = '';
  }

  List<Widget> getExerciseFields(Exercise ex) => [
        CustomFormFields.weightField(
          controller: weightController,
          label: 'Weight',
          isSingle: !ex.isDouble,
          last: ex.userExerciseDetails?.getLastAsString(),
          max: ex.userExerciseDetails?.getPRAsString(),
        ),
        CustomFormFields.intField(
          controller: repsController,
          label: 'Reps',
          selectableValues: [1, 8, 12],
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
                weight: double.parse(getNumberStringOrDefault(weightController.text)),
                reps: int.parse(getNumberStringOrDefault(repsController.text)),
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
              const Divider(thickness: 0.5),
              ExercisePicker(
                exerciseId: widget.exerciseId,
                exercise: selectedExercise,
                categoryShellIds: widget.categoryShellIds,
                autoOpen: true,
                onQuickAdd: onQuickAdd,
                setExercise: (newExercise) => setState(() {
                  selectedExercise = newExercise;
                  resetWeightAndReps();
                }),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              if (selectedExercise != null) ...getExerciseFields(selectedExercise!),
              if (selectedExercise != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.exerciseId == null
                          ? ElevatedButton(
                              onPressed: () => onSubmit(addThree: true),
                              child: const Text('Add 3'),
                            )
                          : const SizedBox.shrink(),
                      ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text('Add'),
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
