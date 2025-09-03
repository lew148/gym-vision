import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/common/forms/fields/exercise_picker.dart';
import 'package:gymvision/static_data/enums.dart';
import 'fields/custom_form_fields.dart';

class AddSetToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final String? exerciseIdentifier;
  final List<Category>? setCategories;
  final List<String>? excludedExercises;
  final Function reloadState;
  final Function? onSuccess;

  const AddSetToWorkoutForm({
    super.key,
    required this.workoutId,
    this.exerciseIdentifier,
    this.setCategories,
    this.excludedExercises,
    required this.reloadState,
    this.onSuccess,
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
          canBeBlank: false,
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
    if (subject == null ||
        !formKey.currentState!.validate() ||
        (!subject.isCardio() && repsController.text == '' || repsController.text == '0')) {
      return; // todo: show error
    }

    Navigator.pop(context);

    try {
      var weId = // get existing or create workoutExercise
          (await WorkoutExerciseModel.getWorkoutExerciseByWorkoutAndExercise(widget.workoutId, subject.identifier))
                  ?.id ??
              await WorkoutExerciseModel.insert(WorkoutExercise(
                workoutId: widget.workoutId,
                exerciseIdentifier: subject.identifier,
                setOrder: '',
              ));

      if (quickAddExercise != null) {
        widget.reloadState();
        return;
      }

      for (int i = 0; i < (addThree ? 3 : 1); i++) {
        await WorkoutSetModel.insert(
          WorkoutSet(
            workoutExerciseId: weId,
            weight: NumberHelper.parseDouble(weightController.text),
            reps: int.parse(NumberHelper.getNumberString(repsController.text)),
            time: duration,
            distance: NumberHelper.parseDouble(distanceController.text),
            calsBurned: int.parse(NumberHelper.getNumberString(calsBurnedController.text)),
          ),
        );
      }

      if (widget.onSuccess != null) widget.onSuccess!();
      widget.reloadState();
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to add set(s) to workout');
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
          CommonUI.getDivider(),
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
          // if (selectedExercise != null && selectedpExercise!.exerciseType == ExerciseType.stretch)
          //   ...getWeightFields(selectedExercise!),
          if (selectedExercise != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectedExercise?.type != ExerciseType.cardio
                      ? CommonUI.getTextButton(ButtonDetails(onTap: () => onSubmit(addThree: true), text: 'Add 3'))
                      : const SizedBox.shrink(),
                  CommonUI.getDoneButton(onSubmit),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
