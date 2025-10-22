import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/logo.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SharableWorkoutSummary extends StatelessWidget {
  final Workout workout;

  const SharableWorkoutSummary({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();

    Future<void> shareCard() async {
      try {
        final image = await screenshotController.capture();
        if (image == null) return;

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/wrokout_summary.png');
        await file.writeAsBytes(image);

        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: '${DateTimeHelper.getDateOrDayStr(workout.date)}\'s ${workout.getWorkoutTitle()} 🏋️ #Forged',
        ));
      } catch (e) {
        if (context.mounted) showSnackBar(context, 'Could not share summary');
      }
    }

    Widget getStatsBreakdown(WorkoutSummary summary) => summary.totalExercises == 0
        ? const SizedBox.shrink()
        : Column(
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

    String getSetGroupKey(WorkoutSet set) => '${set.weight ?? 0}.${set.reps ?? 0}';

    Widget getGroupedSetsBreakdown(WorkoutExercise we, {String? betSetKey}) {
      final groupedSets = groupBy(we.getSets(), getSetGroupKey);

      return Wrap(
        alignment: WrapAlignment.start,
        direction: Axis.horizontal,
        children: groupedSets.entries.map((entry) {
          final set = entry.value.first;
          return Row(children: [
            CustomCard(
              margin: EdgeInsets.only(top: 2.5),
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithIcon.weight(set.weight, muted: true),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 2.5)),
                  TextWithIcon.reps(set.reps, muted: true),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 2.5)),
            Text('x ${entry.value.length}', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            if (betSetKey == getSetGroupKey(set)) ...[
              const Padding(padding: EdgeInsets.all(5)),
              Icon(Icons.star_rounded, color: Colors.amber[300]),
            ],
          ]);
        }).toList(),
      );
    }

    Widget getWorkoutExerciseSummariesListView({required Workout workout, required WorkoutSummary summary}) {
      final workoutExercises = workout.getDoneWorkoutExercises();

      return ListView.builder(
        shrinkWrap: true,
        itemCount: workoutExercises.length,
        itemBuilder: (BuildContext context, int i) {
          final we = workoutExercises[i];
          return Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Icon(Icons.circle_rounded, size: 8, color: Theme.of(context).colorScheme.primary),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text(we.exercise!.getFullName()),
                    ]),
                    if (we.getSets().isNotEmpty && !we.isCardio())
                      getGroupedSetsBreakdown(
                        we,
                        betSetKey: summary.bestSet == null ? null : getSetGroupKey(summary.bestSet!),
                      ),
                  ],
                ),
              ),
            ]),
          );
        },
      );
    }

    Widget getSharableSection(WorkoutSummary? summary) => Screenshot(
          controller: screenshotController,
          child: Container(
            // constraints: BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: summary == null
                  ? [
                      ShimmerLoad(height: 20),
                      ShimmerLoad(height: 80),
                      ShimmerLoad(),
                      ShimmerLoad(),
                    ]
                  : [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.getWorkoutTitle(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              TextWithIcon.date(workout.date),
                              Row(children: [
                                TextWithIcon.time(workout.date),
                                if (workout.isFinished()) ...[
                                  const Padding(padding: EdgeInsetsGeometry.all(5)),
                                  TextWithIcon.timeElapsed(workout.getDuration()),
                                ],
                              ]),
                            ],
                          ),
                          getStatsBreakdown(summary),
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
                      if (workout.getWorkoutExercises().isNotEmpty) ...[
                        const CustomDivider(shadow: true),
                        Container(
                          constraints: BoxConstraints(maxHeight: 500),
                          child: getWorkoutExerciseSummariesListView(workout: workout, summary: summary),
                        ),
                      ],
                      //   const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [Logo()]),
                    ],
            ),
          ),
        );

    return Center(
      child: Column(children: [
        FutureBuilder(
          future: WorkoutModel.getWorkoutSummary(id: workout.id!),
          builder: (context, snapshot) => getSharableSection(snapshot.data),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button.elevated(
              icon: Icons.celebration_rounded,
              text: 'Relive the Glory!',
              onTap: () =>
                  Confetti.launch(context, options: const ConfettiOptions(particleCount: 200, spread: 70, y: 0.8)),
            ),
            Button.elevated(icon: Icons.share_rounded, text: 'Share Workout', onTap: shareCard),
          ],
        ),
      ]),
    );
  }
}
