import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/workouts/set_info_widget.dart';

class WorkoutExerciseSummary extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final WorkoutSet? bestSet;

  const WorkoutExerciseSummary({
    super.key,
    required this.workoutExercise,
    this.bestSet,
  });

  @override
  State<StatefulWidget> createState() => _WorkoutExerciseSummaryState();
}

class _WorkoutExerciseSummaryState extends State<WorkoutExerciseSummary> {
  bool dropped = true;

  String getSetGroupKey(WorkoutSet set) => '${set.weight ?? 0}'
      '.${set.addedWeight ?? 0}'
      '.${set.assistedWeight ?? 0}'
      '.${set.reps ?? 0}'
      '.${set.distance ?? 0}'
      '.${(set.time ?? Duration.zero).inSeconds}'
      '.${set.calsBurned ?? 0}';

  Widget getJoiningDot() => Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: Icon(Icons.circle, color: Theme.of(context).colorScheme.shadow, size: 4),
      );

  List<Widget> getSetMetrics(WorkoutSet set) {
    List<Widget> metrics = [];
    bool firstAdded = false;

    void addSeparator() {
      if (firstAdded) metrics.add(getJoiningDot());
      firstAdded = true;
    }

    if (set.time != null && set.time!.inSeconds != 0) {
      addSeparator();
      metrics.add(Text(DateTimeHelper.getDurationString(set.time!)));
    }

    if (set.distance != null && set.distance != 0) {
      addSeparator();
      metrics.add(Text('${NumberHelper.doubleToString(set.distance)}km'));
    }

    if (set.calsBurned != null && set.calsBurned != 0) {
      addSeparator();
      metrics.add(Text('${set.calsBurned} kcal${set.calsBurned == 1 ? '' : 's'}'));
    }

    if (set.weight != null && set.weight != 0) {
      addSeparator();
      metrics.add(Text('${NumberHelper.doubleToString(set.weight)}kg'));
    }

    if (set.addedWeight != null && set.addedWeight != 0) {
      addSeparator();
      metrics.add(Text('+${NumberHelper.doubleToString(set.addedWeight)}kg'));
    }

    if (set.assistedWeight != null && set.assistedWeight != 0) {
      addSeparator();
      metrics.add(Text('-${NumberHelper.doubleToString(set.assistedWeight)}kg'));
    }

    if (set.reps != null && set.reps != 0) {
      addSeparator();
      metrics.add(Text('${set.reps} rep${set.reps == 1 ? '' : 's'}'));
    }

    return metrics;
  }

  Widget getGroupedSetsBreakdown(List<WorkoutSet> sets, {String? betSetKey}) {
    final groupedSets = groupBy(sets, getSetGroupKey);

    return Wrap(
      alignment: WrapAlignment.start,
      children: groupedSets.entries.map((entry) {
        final set = entry.value.first;
        final isBest = betSetKey == getSetGroupKey(set);

        return CustomCard(
          customElevation: 1,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SetInfoWidget(info: set.info, small: true, padding: EdgeInsets.only(right: 5)),
              if (isBest)
                Padding(
                  padding: EdgeInsetsGeometry.only(right: 5),
                  child: Icon(Icons.star_rounded, color: Colors.amber[300], size: 16),
                ),
              ...getSetMetrics(set),
              if (entry.value.length > 1)
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 5),
                  child: Text(
                    'x${entry.value.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasSets = widget.workoutExercise.getSets().isNotEmpty;

    return AnimatedCrossFade(
      duration: Duration(milliseconds: 100),
      secondChild: SizedBox.shrink(),
      crossFadeState: CrossFadeState.showFirst,
      firstChild: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => setState(() {
          dropped = !dropped;
        }),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle_rounded, size: 8, color: Theme.of(context).colorScheme.primary),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(widget.workoutExercise.exercise!.name),
                      ],
                    ),
                    if (hasSets)
                      dropped
                          ? Icon(Icons.arrow_drop_up_rounded, color: Theme.of(context).colorScheme.shadow)
                          : Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.shadow)
                  ],
                ),
                if (dropped && hasSets)
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 1),
                    child: getGroupedSetsBreakdown(
                      widget.workoutExercise.getDoneSets(),
                      betSetKey: widget.bestSet == null ? null : getSetGroupKey(widget.bestSet!),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
