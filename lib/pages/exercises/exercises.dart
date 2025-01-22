import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../db/classes/exercise.dart';
import '../../enums.dart';
import '../../helpers/ui_helper.dart';
import 'exercise_view.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  Future<List<Exercise>> _exercises = ExercisesHelper.getExercises();

  reloadState() => setState(() {
        _exercises = ExercisesHelper.getExercises();
      });

  Widget getExerciseWidget(Exercise exercise) => Column(children: [
        const Divider(thickness: 0.25, height: 0),
        InkWell(
          onTap: () => Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => ExerciseView(
                    exerciseId: exercise.id!,
                  ),
                ),
              )
              .then((value) => reloadState()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(exercise.name)),
                const Padding(padding: EdgeInsets.all(10)),
                Wrap(children: [
                  if (exercise.equipment != ExerciseEquipment.other)
                    UiHelper.getPropDisplay(context, exercise.equipment.displayName),
                  // exercise.muscleGroup != MuscleGroup.other
                  //     ? getPropDisplay(context, exercise.muscleGroup.displayName)
                  //     : getPropDisplay(context, exercise.exerciseType.displayName),
                ]),
              ],
            ),
          ),
        )
      ]);

  getExercisesContent(Map<int, List<Exercise>> groupedExercises) {
    if (groupedExercises.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No Exercises here :(')));
    }

    final List<Widget> sections = [];

    groupedExercises.forEach((key, value) => sections.add(
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Text(
                  value[0].exerciseType == ExerciseType.cardio
                      ? value[0].exerciseType.displayName
                      : value[0].muscleGroup.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ]),
            ),
            content: Column(children: value.map((e) => getExerciseWidget(e)).toList()),
          ),
        ));

    return Expanded(child: SingleChildScrollView(child: Column(children: sections)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      child: FutureBuilder<List<Exercise>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // loading
          }

          var exercises = snapshot.data!;
          final Map<int, List<Exercise>> groupedExercises =
              groupBy<Exercise, int>(exercises, (e) => e.muscleGroup.index);

          return Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: Column(children: [
              UiHelper.getSectionTitleWithActions(
                context,
                'Exercises',
                [], //[ActionButton(icon: Icons.add_rounded, onTap: () => null)],
              ),
              const Divider(thickness: 0.25),
              getExercisesContent(groupedExercises),
            ]),
          );
        },
      ),
    );
  }
}
