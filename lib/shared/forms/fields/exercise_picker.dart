import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';

import '../../../db/classes/exercise.dart';

class ExercisePicker extends StatefulWidget {
  final int? exerciseId;
  final Function setExercise;

  const ExercisePicker({
    Key? key,
    this.exerciseId,
    required this.setExercise,
  }) : super(key: key);

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  Future<Exercise>? exercise;

  @override
  void initState() {
    super.initState();
    if (widget.exerciseId != null) {
      exercise = ExercisesHelper.getExercise(widget.exerciseId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise>(
      future: exercise,
      builder: ((context, snapshot) {
        // all ontap will open picker

        if (!snapshot.hasData) {
          return const Text('select exercise');
        }

        return Text(snapshot.data!.name);
      }),
    );
  }
}
