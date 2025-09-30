import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/custom_vertical_divider.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/pages/workout/workout_options_menu.dart';

class WorkoutSummaryCard extends StatefulWidget {
  final int workoutId;
  final bool isDisplay;

  const WorkoutSummaryCard({
    super.key,
    required this.workoutId,
    this.isDisplay = false,
  });

  @override
  State<StatefulWidget> createState() => _WorkoutSummaryCardState();
}

class _WorkoutSummaryCardState extends State<WorkoutSummaryCard> {
  late Future<Workout?> workoutFuture;

  @override
  void initState() {
    super.initState();
    workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withSummary: true);
  }

  void reload() => setState(() {
        workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withSummary: true);
      });

  Widget getWorkoutSummary(int workoutId, WorkoutSummary? summary) => summary == null || summary.totalExercises == 0
      ? const SizedBox.shrink()
      : Column(children: [
          const CustomDivider(shadow: true),
          Container(
            padding: const EdgeInsets.all(5),
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: summary.totalReps + summary.totalSets == 0
                  ? [
                      Text(
                        summary.getTotalExercisesString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ]
                  : [
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            summary.getTotalExercisesString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                      const CustomVerticalDivider(),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            summary.getTotalSetsString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                      const CustomVerticalDivider(),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            summary.getTotalRepsString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                    ],
            ),
          ),
          const CustomDivider(shadow: true),
          if (summary.bestSet != null && summary.bestSetExercise != null)
            CustomCard(
              onTap: () => openWorkoutView(
                context,
                workoutId,
                onClose: reload,
                droppedWes: [summary.bestSet!.workoutExerciseId],
              ),
              color: AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[300]),
                    const Padding(padding: EdgeInsets.all(5)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(summary.bestSetExercise!.getFullName()),
                        Row(children: [
                          TextWithIcon.weight(summary.bestSet!.weight, muted: true),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                          TextWithIcon.reps(summary.bestSet!.reps, muted: true),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (summary.note != null)
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  summary.note!,
                  style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
        ]);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder(
          future: workoutFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Row(children: [SizedBox(height: 120)]); // todo: shimmer loader

            final workout = snapshot.data!;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => openWorkoutView(context, workout.id!, onClose: reload),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                          workout.isFinished() ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: workout.isFinished() ? Theme.of(context).colorScheme.primary : Colors.grey,
                          size: 22,
                        ),
                        const Padding(padding: EdgeInsetsGeometry.all(5)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.getWorkoutTitle(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (widget.isDisplay) TextWithIcon.date(workout.date),
                            Row(children: [
                              TextWithIcon.time(workout.date, dtEnd: workout.endDate),
                              if (workout.isFinished()) ...[
                                const Padding(padding: EdgeInsetsGeometry.all(5)),
                                TextWithIcon.timeElapsed(workout.getDuration()),
                              ],
                            ]),
                          ],
                        ),
                      ]),
                      WorkoutOptionsMenu(
                        workout: workout,
                        onChange: reload,
                      ),
                    ],
                  ),
                  if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsGeometry.only(top: 5),
                      child: Row(children: [
                        Expanded(
                          child: Wrap(
                            children: workout
                                .getCategories()
                                .map((c) => PropDisplay(
                                      text: c.displayName,
                                      color: AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
                                    ))
                                .toList(),
                          ),
                        ),
                      ]),
                    ),
                  getWorkoutSummary(workout.id!, workout.summary),
                  Padding(
                    padding: const EdgeInsetsGeometry.only(top: 10),
                    child: Row(children: [
                      if (workout.summary?.note == null)
                        Padding(
                          padding: const EdgeInsetsGeometry.only(right: 20),
                          child: Button(
                            text: 'Add Note',
                            icon: Icons.add_rounded,
                            style: ButtonCustomStyle.noPadding(),
                            onTap: () => openWorkoutView(context, workout.id!, onClose: reload, autofocusNotes: true),
                          ),
                        ),
                      Button(
                        text: 'Add Progress Pic',
                        icon: Icons.add_rounded,
                        style: ButtonCustomStyle.noPadding(),
                        onTap: () => null,
                      ),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
