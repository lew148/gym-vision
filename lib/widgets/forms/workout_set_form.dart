import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/models/db_models/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';
import 'package:gymvision/widgets/forms/fields/duration_field.dart';

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

  void setWeight(String s) => weightController.text = s;
  void setReps(String s) => repsController.text = s;

  List<Widget> getWeightFields(Exercise ex) {
    return [
      CustomFormField.double(controller: weightController, label: 'Weight', unit: 'kg'),
      CustomFormField.int(
        controller: repsController,
        label: 'Reps',
        canBeBlank: false,
        buttons: [
          Button(text: '1', onTap: () => setReps('1'), style: ButtonCustomStyle.noPrimary()),
          Button(text: '8', onTap: () => setReps('8'), style: ButtonCustomStyle.noPrimary()),
          Button(text: '10', onTap: () => setReps('10'), style: ButtonCustomStyle.noPrimary()),
          Button(text: '12', onTap: () => setReps('12'), style: ButtonCustomStyle.noPrimary()),
        ],
      ),
    ];
  }

  List<Widget> getCardioFields(Exercise ex) => [
        DurationField(
          label: 'Time',
          duration: duration,
          onChange: (Duration newDuration) => setState(() => duration = newDuration),
        ),
        CustomFormField.double(
          controller: distanceController,
          label: 'Distance',
          unit: 'km',
          buttons: [Button.clear(onTap: () => distanceController.clear())],
        ),
        CustomFormField.int(
          controller: calsBurnedController,
          label: 'Cals Burned',
          unit: 'kcal',
          buttons: [Button.clear(onTap: () => calsBurnedController.clear())],
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
        widget.onSuccess();
      } catch (ex) {
        if (!mounted) return;
        showSnackBar(context, 'Failed to edit workout set');
      }
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
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();

        if (!snapshot.hasData) {
          return const SplashText(
            title: 'This exercise cannot be found',
            icon: Icons.question_mark_rounded,
          );
        }

        final Exercise exercise = snapshot.data!;
        final MapEntry? maxStrings = exercise.exerciseDetails?.getMaxStrings();
        final MapEntry? lastStrings = exercise.exerciseDetails?.getLastStrings();

        return Form(
          key: formKey,
          child: Column(
            children: [
              Header(title: exercise.getFullName()),
              const CustomDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (lastStrings != null)
                    Button(
                      text: 'Last',
                      onTap: () {
                        if (lastStrings.key != null) setWeight(lastStrings.key);
                        if (lastStrings.value != null) setReps(lastStrings.value);
                      },
                    ),
                  if (maxStrings != null)
                    Button(
                        text: 'Max',
                        onTap: () {
                          if (maxStrings.key != null) setWeight(maxStrings.key);
                          if (maxStrings.value != null) setReps(maxStrings.value);
                        }),
                ],
              ),
              if (exercise.type == ExerciseType.strength) ...getWeightFields(exercise),
              if (exercise.type == ExerciseType.cardio) ...getCardioFields(exercise),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isEdit
                      ? [
                          Row(children: [
                            Button.delete(onTap: onDeleteButtonTap),
                            Button(icon: Icons.copy_rounded, onTap: onCopySetButtonTap),
                          ]),
                          Button.done(onTap: onEditSubmit),
                        ]
                      : [
                          exercise.type != ExerciseType.cardio
                              ? Button(onTap: () => onAddSubmit(exercise, addThree: true), text: 'Add 3')
                              : const SizedBox.shrink(),
                          Button.done(onTap: () => onAddSubmit(exercise), isAdd: true),
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
