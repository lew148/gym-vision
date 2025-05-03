import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';

class ExerciseRecentUsesView extends StatefulWidget {
  final List<WorkoutSet> workoutSets;
  final Exercise exercise;

  const ExerciseRecentUsesView({
    super.key,
    required this.workoutSets,
    required this.exercise,
  });

  @override
  State<ExerciseRecentUsesView> createState() => _ExerciseRecentUsesViewState();
}

class _ExerciseRecentUsesViewState extends State<ExerciseRecentUsesView> {
  List<Widget> getWorkoutExerciseWidget(List<WorkoutSet> sets) => sets
      .map((set) => Column(children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: widget.exercise.type == ExerciseType.strength
                    ? [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.shadow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (sets.indexOf(set) + 1).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: set.hasWeight()
                                ? [
                                    const Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.fitness_center_rounded,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(5)),
                                    Expanded(child: Text(set.getWeightDisplay())),
                                  ]
                                : [dashIcon()],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.repeat_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(set.getRepsDisplay()),
                            ],
                          ),
                        ),
                      ]
                    : [
                        Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: set.hasTime()
                                  ? [
                                      const Icon(
                                        Icons.timer_rounded,
                                        size: 15,
                                      ),
                                      const Padding(padding: EdgeInsets.all(5)),
                                      Text(set.getTimeDisplay()),
                                    ]
                                  : [dashIcon()],
                            )),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: set.hasDistance()
                                ? [
                                    const Icon(
                                      Icons.timeline_rounded,
                                      size: 15,
                                    ),
                                    const Padding(padding: EdgeInsets.all(5)),
                                    Text(set.getDistanceDisplay()),
                                  ]
                                : [dashIcon()],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: set.hasCalsBurned()
                                ? [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 15,
                                    ),
                                    const Padding(padding: EdgeInsets.all(5)),
                                    Text(set.getCalsBurnedDisplay()),
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
        CommonUI.getCard(
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CommonUI.getCompleteMark(widget.workoutSets.first.workoutExercise?.done ?? false),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(
                    widget.workoutSets.first.getWorkout()?.getDateStr() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 0.25, height: 0),
            ...getWorkoutExerciseWidget(widget.workoutSets),
          ]),
        ),
      ],
    );
  }
}
