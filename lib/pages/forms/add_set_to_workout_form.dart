import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'fields/custom_form_fields.dart';
import 'fields/exercise_picker.dart';

class AddSetToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final String? exerciseIdentifier;
  final List<Category>? setCategories;
  final List<String>? excludedExercises;
  final Function reloadState;

  const AddSetToWorkoutForm({
    super.key,
    required this.workoutId,
    this.exerciseIdentifier,
    this.setCategories,
    this.excludedExercises,
    required this.reloadState,
  });

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

  void onSubmit({bool addThree = false, Exercise? quickAddExercise}) async {
    final subject = quickAddExercise ?? selectedExercise;
    if (subject == null) return; // todo: show error

    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        var weId = //get existing or create workoutExercise
            (await WorkoutExerciseModel.getWorkoutExerciseByWorkoutAndExercise(widget.workoutId, subject.identifier))
                    ?.id ??
                await WorkoutExerciseModel.insertWorkoutExercise(WorkoutExercise(
                  workoutId: widget.workoutId,
                  exerciseIdentifier: subject.identifier,
                ));

        if (quickAddExercise != null) {
          widget.reloadState();
          return;
        }

        for (int i = 0; i < (addThree ? 3 : 1); i++) {
          await WorkoutSetModel.addSetToWorkout(
            WorkoutSet(
              workoutExerciseId: weId,
              weight: double.parse(getNumberString(weightController.text)),
              reps: int.parse(getNumberString(repsController.text)),
              time: duration,
              distance: double.parse(getNumberString(distanceController.text)),
              calsBurned: int.parse(getNumberString(calsBurnedController.text)),
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
    onSubmit(quickAddExercise: exercise);
    Navigator.of(context).pop(); // closing picker
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CommonUI.getSectionTitleWithCloseButton(context, 'Add Set'),
          CommonUI.getDefaultDivider(),
          ExercisePicker(
            exerciseIdentifier: widget.exerciseIdentifier,
            exercise: selectedExercise,
            setCategories: widget.setCategories,
            excludedExercises: widget.excludedExercises,
            autoOpen: true,
            onQuickAdd: onQuickAdd,
            setExerciseForParent: (newExercise) => setState(() {
              selectedExercise = newExercise;
              weightController.text = '';
              repsController.text = '';
            }),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          if (selectedExercise != null && selectedExercise!.type == ExerciseType.strength)
            ...getWeightFields(selectedExercise!),
          if (selectedExercise != null && selectedExercise!.type == ExerciseType.cardio)
            ...getCardioFields(selectedExercise!),
          // if (selectedExercise != null && selectedExercise!.exerciseType == ExerciseType.stretch)
          //   ...getWeightFields(selectedExercise!),
          if (selectedExercise != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectedExercise?.type != ExerciseType.cardio
                      ? CommonUI.getElevatedPrimaryButton(
                          context,
                          ButtonDetails(onTap: () => onSubmit(addThree: true), text: 'Add 3'),
                        )
                      : const SizedBox.shrink(),
                  CommonUI.getElevatedPrimaryButton(context, ButtonDetails(onTap: onSubmit, text: 'Add')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
