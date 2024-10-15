import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/enums.dart';

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
  Widget dashIcon() => const Center(
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  List<Widget> getWorkoutExerciseWidget(List<WorkoutSet> ws) => ws
      .map((s) => s.isPlaceholder()
          ? const SizedBox.shrink()
          : Column(children: [
              Divider(height: 0, thickness: ws.indexOf(s) == 1 ? 1 : 0.25),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: s.exercise!.exerciseType == ExerciseType.weight
                      ? [
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: s.hasWeight()
                                  ? [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                          const Icon(
                                            Icons.fitness_center_rounded,
                                            size: 15,
                                          ),
                                          if (s.single)
                                            const Icon(
                                              Icons.fitness_center_rounded,
                                              size: 15,
                                            ),
                                        ],),
                                      ),
                                      const Padding(padding: EdgeInsets.all(5)),
                                      Expanded(child: Text(s.getWeightDisplay())),
                                    ]
                                  : [dashIcon()],
                            ),
                          ),
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
                        ]
                      : [
                          Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: s.hasTime()
                                    ? [
                                        const Icon(
                                          Icons.timer_rounded,
                                          size: 15,
                                        ),
                                        const Padding(padding: EdgeInsets.all(5)),
                                        Text(s.getTimeDisplay()),
                                      ]
                                    : [dashIcon()],
                              )),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: s.hasDistance()
                                  ? [
                                      const Icon(
                                        Icons.timeline_rounded,
                                        size: 15,
                                      ),
                                      const Padding(padding: EdgeInsets.all(5)),
                                      Text(s.getDistanceDisplay()),
                                    ]
                                  : [dashIcon()],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: s.hasCalsBurned()
                                  ? [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 15,
                                      ),
                                      const Padding(padding: EdgeInsets.all(5)),
                                      Text(s.getCalsBurnedDisplay()),
                                    ]
                                  : [dashIcon()],
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
                    widget.workoutSets[0].workout!.getDateStr(),
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
