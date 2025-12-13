import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/confetti_helper.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox_with_label.dart';
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
  final _formKey = GlobalKey<FormState>();
  late bool _isEdit;
  late Future<Exercise?> _exerciseFuture;

  late bool _complete;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _distanceController;
  late TextEditingController _calsBurnedController;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _exerciseFuture = DefaultExercisesModel.getExerciseWithDetails(identifier: widget.exerciseIdentifier);

    _isEdit = widget.workoutSet != null;
    _complete = _isEdit ? widget.workoutSet?.done ?? false : false;

    _weightController = TextEditingController(
      text: _isEdit ? NumberHelper.blankIfZero(NumberHelper.doubleToString(widget.workoutSet!.weight)) : null,
    );

    _repsController = TextEditingController(
      text: _isEdit ? NumberHelper.blankIfZero(widget.workoutSet!.reps.toString()) : null,
    );

    _distanceController = TextEditingController(
      text: _isEdit ? NumberHelper.blankIfZero(NumberHelper.doubleToString(widget.workoutSet!.distance)) : null,
    );

    _calsBurnedController = TextEditingController(
      text: _isEdit ? NumberHelper.blankIfZero(widget.workoutSet!.calsBurned.toString()) : null,
    );

    _duration = widget.workoutSet?.time ?? const Duration();
  }

  void setWeight(String s) => _weightController.text = s;
  void setReps(String s) => _repsController.text = s;

  List<Widget> getWeightFields(Exercise ex) {
    return [
      CustomFormField.double(
        controller: _weightController,
        label: 'Weight',
        unit: 'kg',
        prefixIcon: Icons.fitness_center_rounded,
      ),
      CustomFormField.int(
        controller: _repsController,
        label: 'Reps',
        prefixIcon: Icons.repeat_rounded,
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
          duration: _duration,
          onChange: (Duration newDuration) => setState(() => _duration = newDuration),
        ),
        CustomFormField.double(
          controller: _distanceController,
          label: 'Distance',
          unit: 'km',
          prefixIcon: Icons.timeline_rounded,
        ),
        CustomFormField.int(
          controller: _calsBurnedController,
          label: 'Cals Burned',
          unit: 'kcal',
          prefixIcon: Icons.local_fire_department_rounded,
        ),
      ];

  Future onSubmit({Exercise? exercise, bool addThree = false}) async {
    WorkoutSet? set;
    final max = await WorkoutSetModel.getPR(widget.exerciseIdentifier);

    if (exercise == null) {
      set = await onEditSubmit();
    } else {
      set = await onAddSubmit(exercise, addThree: addThree);
    }

    if (set == null) return;
    if (mounted) Navigator.pop(context);

    if (max != null && set.done && set.isGreaterThan(max)) {
      if (mounted) ConfettiHelper.bothSidesInward(context);
    }
  }

  Future<WorkoutSet?> onAddSubmit(Exercise exercise, {bool addThree = false}) async {
    if (!_formKey.currentState!.validate()) return null;

    try {
      final we = await WorkoutExerciseModel.getWorkoutExerciseByWorkoutAndExercise(
        widget.workoutId,
        exercise.identifier,
        createIfNotFound: true,
      );

      final set = WorkoutSet(
        workoutExerciseId: we!.id!,
        weight: NumberHelper.parseDouble(_weightController.text),
        reps: int.parse(NumberHelper.getNumberString(_repsController.text)),
        time: _duration,
        distance: NumberHelper.parseDouble(_distanceController.text),
        calsBurned: int.parse(NumberHelper.getNumberString(_calsBurnedController.text)),
        done: _complete,
      );

      for (int i = 0; i < (addThree ? 3 : 1); i++) {
        await WorkoutSetModel.insert(set);
      }

      widget.onSuccess();
      return set;
    } catch (ex) {
      if (mounted) AppHelper.showSnackBar(context, 'Failed to add set(s) to workout');
      return null;
    }
  }

  Future<WorkoutSet?> onEditSubmit() async {
    if (!_formKey.currentState!.validate()) return null;

    bool hasChanges = false;

    try {
      final newWeight = NumberHelper.parseDouble(_weightController.text);
      final newReps = int.parse(NumberHelper.getNumberString(_repsController.text));
      final newDistance = NumberHelper.parseDouble(_distanceController.text);
      final newCalsBurned = int.parse(NumberHelper.getNumberString(_calsBurnedController.text));
      final newDuration = _duration;

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

      if (set.done != _complete) {
        set.done = _complete;
        hasChanges = true;
      }

      if (!hasChanges) return set;

      await WorkoutSetModel.update(set);
      widget.onSuccess();
      return set;
    } catch (ex) {
      if (mounted) AppHelper.showSnackBar(context, 'Failed to edit workout set');
      return null;
    }
  }

  void onDeleteButtonTap() async {
    Navigator.pop(context);
    try {
      await WorkoutSetModel.delete(widget.workoutSet!.id!);
    } catch (ex) {
      if (!mounted) return;
      AppHelper.showSnackBar(context, 'Failed to remove set from workout');
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
      AppHelper.showSnackBar(context, 'Failed add set to workout');
    }

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise?>(
      future: _exerciseFuture,
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
          key: _formKey,
          child: Column(
            children: [
              Header(title: exercise.getFullName()),
              const CustomDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomCheckboxWithLabel(
                    label: 'Complete',
                    value: _complete,
                    onChange: (value) => setState(() {
                      _complete = value;
                    }),
                  ),
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
                ],
              ),
              if (exercise.type == ExerciseType.strength) ...getWeightFields(exercise),
              if (exercise.type == ExerciseType.cardio) ...getCardioFields(exercise),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _isEdit
                      ? [
                          Row(children: [
                            Button.delete(onTap: onDeleteButtonTap),
                            Button(icon: Icons.copy_rounded, onTap: onCopySetButtonTap),
                          ]),
                          Button.submit(onTap: onSubmit),
                        ]
                      : [
                          exercise.type != ExerciseType.cardio
                              ? Button(onTap: () => onSubmit(exercise: exercise, addThree: true), text: 'Add 3')
                              : const SizedBox.shrink(),
                          Button.submit(onTap: () => onSubmit(exercise: exercise), text: 'Add'),
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
