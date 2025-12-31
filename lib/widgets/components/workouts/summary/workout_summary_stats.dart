import 'package:flutter/material.dart';
import 'package:gymvision/classes/workout_summary.dart';

class WorkoutSummaryStats extends StatelessWidget {
  final WorkoutSummary? summary;

  const WorkoutSummaryStats({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (summary == null || summary!.totalExercises == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: summary!.totalReps + summary!.totalSets == 0
          ? [
              Text(
                summary!.getTotalExercisesString(),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ]
          : [
              Text(
                summary!.getTotalExercisesString(),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                summary!.getTotalSetsString(),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                summary!.getTotalRepsString(),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
    );
  }
}
