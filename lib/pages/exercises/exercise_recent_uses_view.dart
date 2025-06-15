import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/classes/exercise.dart';
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
      .map(
        (set) => Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: widget.exercise.type == ExerciseType.strength
                ? [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (sets.indexOf(set) + 1).toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CommonUI.getWeightWithIcon(set),
                    ),
                    Expanded(
                      flex: 4,
                      child: CommonUI.getRepsWithIcon(set),
                    ),
                  ]
                : [
                    Expanded(
                      flex: 3,
                      child: CommonUI.getTimeWithIcon(set),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonUI.getDistanceWithIcon(set),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonUI.getCaloriesWithIcon(set),
                    ),
                  ],
          ),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return CommonUI.getCard(
      context,
      Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Row(
            children: [
              CommonUI.getCompleteMark(context, widget.workoutSets.first.workoutExercise?.done ?? false),
              const Padding(padding: EdgeInsets.all(5)),
              Text(
                widget.workoutSets.first.getWorkout()?.getDateStr() ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...getWorkoutExerciseWidget(widget.workoutSets),
      ]),
    );
  }
}
