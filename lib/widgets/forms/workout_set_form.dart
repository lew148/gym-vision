import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/widgets/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'fields/custom_form_fields.dart';

class WorkoutSetForm extends StatefulWidget {
  final int workoutId;
  final String exerciseIdentifier;
  final Function onSuccess;
  final WorkoutSet? workoutSet;

  const WorkoutSetForm({
    super.key,
    required this.workoutId,
    required this.exerciseIdentifier,
    required this.onSuccess,
    this.workoutSet,
  });

  @override
  State<WorkoutSetForm> createState() => _WorkoutSetFormState();
}

class _WorkoutSetFormState extends State<WorkoutSetForm> {
  final formKey = GlobalKey<FormState>();
  late bool isEdit;
  late Future<Exercise?> exerciseFuture;

  late TextEditingController weightController;
  late TextEditingController repsController;
  late TextEditingController distanceController;
  late TextEditingController calsBurnedController;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    exerciseFuture = DefaultExercisesModel.getExerciseWithDetails(identifier: widget.exerciseIdentifier);

    isEdit = widget.workoutSet != null;
    weightController = TextEditingController(
      text: isEdit ? NumberHelper.blankIfZero(NumberHelper.truncateDouble(widget.workoutSet!.weight)) : null,
    );

    repsController = TextEditingController(
      text: isEdit ? NumberHelper.blankIfZero(widget.workoutSet!.reps.toString()) : null,
    );

    distanceController = TextEditingController(
      text: isEdit ? NumberHelper.blankIfZero(NumberHelper.truncateDouble(widget.workoutSet!.distance)) : null,
    );

    calsBurnedController = TextEditingController(
      text: isEdit ? NumberHelper.blankIfZero(widget.workoutSet!.calsBurned.toString()) : null,
    );

    duration = widget.workoutSet?.time ?? const Duration();
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

  void onAddSubmit(Exercise exercise, {bool addThree = false}) async {
    if (!formKey.currentState!.validate() ||
        (!exercise.isCardio() && repsController.text == '' || repsController.text == '0')) {
      return;
    }

    Navigator.pop(context);

    try {
      var we = await WorkoutExerciseModel.getWorkoutExerciseByWorkoutAndExercise(
        widget.workoutId,
        exercise.identifier,
        createIfNotFound: true,
      );

      for (int i = 0; i < (addThree ? 3 : 1); i++) {
        await WorkoutSetModel.insert(
          WorkoutSet(
            workoutExerciseId: we!.id!,
            weight: NumberHelper.parseDouble(weightController.text),
            reps: int.parse(NumberHelper.getNumberString(repsController.text)),
            time: duration,
            distance: NumberHelper.parseDouble(distanceController.text),
            calsBurned: int.parse(NumberHelper.getNumberString(calsBurnedController.text)),
          ),
        );
      }

      widget.onSuccess();
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to add set(s) to workout');
    }
  }

  void onEditSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      bool hasChanges = false;

      try {
        final newWeight = NumberHelper.parseDouble(weightController.text);
        final newReps = int.parse(NumberHelper.getNumberString(repsController.text));
        final newDistance = NumberHelper.parseDouble(distanceController.text);
        final newCalsBurned = int.parse(NumberHelper.getNumberString(calsBurnedController.text));
        final newDuration = duration;

        final set = widget.workoutSet!;
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

        await WorkoutSetModel.update(set);
      } catch (ex) {
        if (!mounted) return;
        showSnackBar(context, 'Failed to edit workout set');
      }

      widget.onSuccess();
    }
  }

  void onDeleteButtonTap() async {
    Navigator.pop(context);
    try {
      await WorkoutSetModel.delete(widget.workoutSet!.id!);
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to remove set from workout');
    }

    widget.onSuccess();
  }

  void onCopySetButtonTap() async {
    try {
      HapticFeedback.lightImpact();

      final set = widget.workoutSet!;
      await WorkoutSetModel.insert(
        WorkoutSet(
          workoutExerciseId: set.workoutExerciseId,
          weight: set.weight,
          time: set.time,
          distance: set.distance,
          calsBurned: set.calsBurned,
          reps: set.reps,
          done: false,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed add set to workout');
    }

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise?>(
      future: exerciseFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: Text('This exercise cannot be found.'));

        final exercise = snapshot.data!;

        return Form(
          key: formKey,
          child: Column(
            children: [
              CommonUI.getSectionTitle(context, exercise.getFullName()),
              CommonUI.getDivider(),
              if (exercise.type == ExerciseType.strength) ...getWeightFields(exercise),
              if (exercise.type == ExerciseType.cardio) ...getCardioFields(exercise),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isEdit
                      ? [
                          Row(children: [
                            CommonUI.getDeleteButton(onDeleteButtonTap),
                            CommonUI.getTextButton(
                              ButtonDetails(icon: Icons.copy_rounded, onTap: onCopySetButtonTap),
                            ),
                          ]),
                          CommonUI.getDoneButton(onEditSubmit),
                        ]
                      : [
                          exercise.type != ExerciseType.cardio
                              ? CommonUI.getTextButton(
                                  ButtonDetails(onTap: () => onAddSubmit(exercise, addThree: true), text: 'Add 3'),
                                )
                              : const SizedBox.shrink(),
                          CommonUI.getDoneButton(() => onAddSubmit(exercise), isAdd: true),
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
