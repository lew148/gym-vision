import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';

class ExerciseRecentUsesView extends StatefulWidget {
  final List<WorkoutSet> workoutSets;

  const ExerciseRecentUsesView({
    super.key,
    required this.workoutSets,
  });

  @override
  State<ExerciseRecentUsesView> createState() => _ExerciseRecentUsesViewState();
}

class _ExerciseRecentUsesViewState extends State<ExerciseRecentUsesView> {
  List<Widget> getWorkoutExerciseWidget(List<WorkoutSet> ws) => ws
      .map((s) => s.isPlaceholder()
          ? const SizedBox.shrink()
          : Column(children: [
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: s.hasWeight()
                              ? [
                                  const Icon(
                                    Icons.fitness_center_rounded,
                                    size: 15,
                                  ),
                                  const Padding(padding: EdgeInsets.all(5)),
                                  Text(s.getWeightDisplay()),
                                ]
                              : [
                                  const Center(
                                    child: Text(
                                      '-',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                ],
                        )),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.repeat_rounded,
                            size: 15,
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(s.getRepsDisplay()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    widget.workoutSets[0].workout!.getDateAndTimeString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...getWorkoutExerciseWidget(widget.workoutSets),
          ]),
        ),
      ],
    );
  }
}
