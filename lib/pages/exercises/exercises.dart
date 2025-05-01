import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/pages/exercises/exercise_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  static List<Exercise> exercises = DefaultExercisesModel.getExercises();

  reloadState() => setState(() {});

  Widget getExerciseWidget(Exercise exercise) => Column(children: [
        InkWell(
          onTap: () => Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (context) => ExerciseView(identifier: exercise.identifier)),
              )
              .then((value) => reloadState()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [Expanded(child: Text(exercise.name))]),
          ),
        ),
        const Divider(thickness: 0.25, height: 0),
      ]);

  getExercisesContent(Map<int, List<Exercise>> groupedExercises) {
    if (groupedExercises.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No Exercises here :(')));
    }

    final List<Widget> sections = [];

    groupedExercises.forEach((key, value) => sections.add(Column(
          children: [
            StickyHeader(
              header: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  Text(
                    value[0].type == ExerciseType.cardio
                        ? value[0].type.displayName
                        : value[0].primaryMuscleGroup.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ]),
              ),
              content: Column(children: value.map((e) => getExerciseWidget(e)).toList()),
            ),
          ],
        )));

    return Expanded(child: SingleChildScrollView(child: Column(children: sections)));
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, List<Exercise>> groupedExercises =
        groupBy<Exercise, int>(exercises, (e) => e.primaryMuscleGroup.index);

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(children: [getExercisesContent(groupedExercises)]),
    );
  }
}
