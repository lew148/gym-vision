import 'package:flutter/material.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/providers/workout_stats_provider.dart';
import 'package:provider/provider.dart';

class WorkoutSummaryStats extends StatelessWidget {
  final int? workoutId;
  final WorkoutSummary? summary;

  const WorkoutSummaryStats({
    super.key,
    this.summary,
    this.workoutId,
  }) : assert(summary != null || workoutId != null, 'Either summary or workoutId must be provided');

  @override
  Widget build(BuildContext context) {
    Widget getStatsColumn(WorkoutSummary? summary) => summary == null || summary.totalExercises == 0
        ? const SizedBox.shrink()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: summary.totalReps + summary.totalSets == 0
                  ? [
                      Text(
                        summary.getTotalExercisesString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ]
                  : [
                      Text(
                        summary.getTotalExercisesString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                      Text(
                        summary.getTotalSetsString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                      Text(
                        summary.getTotalRepsString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
          );

    return Consumer<WorkoutStatsProvider>(
      builder: (_, state, __) => summary == null
          ? FutureBuilder(
              future: WorkoutModel.getWorkoutSummary(id: workoutId, fullSummary: false),
              builder: (context, snapshot) => getStatsColumn(snapshot.data),
            )
          : getStatsColumn(summary),
    );
  }
}
