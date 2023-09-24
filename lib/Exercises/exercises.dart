import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';

import '../db/classes/exercise.dart';
import '../enums.dart';
import '../shared/ui_helper.dart';
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

  Widget getExerciseWidget(Exercise exercise) => Row(children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => ExerciseView(
                        exerciseId: exercise.id!,
                      ),
                    ),
                  )
                  .then((value) => reloadState()),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(3)),
                          Wrap(children: [
                            if (exercise.muscleGroup != MuscleGroup.other)
                              getPropDisplay(context, exercise.muscleGroup.displayName),
                            if (exercise.equipment != ExerciseEquipment.other)
                              getPropDisplay(context, exercise.equipment.displayName),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      child: FutureBuilder<List<Exercise>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          var exercises = snapshot.data!;
          exercises.sort(((a, b) => a.muscleGroup.index.compareTo(b.muscleGroup.index)));

          return Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: Column(children: [
              getSectionTitleWithActions(
                context,
                'Exercises',
                [], //[ActionButton(icon: Icons.add_rounded, onTap: () => null)],
              ),
              const Divider(),
              exercises.isEmpty
                  ? const Center(
                      child: Padding(padding: EdgeInsets.all(20), child: Text('No Exercises here :(')),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Column(
                            children: exercises.map((e) => getExerciseWidget(e)).toList(),
                          ),
                        ),
                      ),
                    ),
            ]),
          );
        },
      ),
    );
  }
}
