import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/logo.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/components/workouts/summary/workout_exercise_summary.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SharableWorkoutSummary extends StatelessWidget {
  final int workoutId;

  const SharableWorkoutSummary({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();

    return FutureBuilder(
        future: WorkoutModel.getWorkout(workoutId, withCategories: true, withExercises: true, withSummary: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(children: [
              ShimmerLoad(height: 30),
              ShimmerLoad(height: 80),
              ShimmerLoad(),
              ShimmerLoad(),
            ]);
          }

          Workout? workout = snapshot.data;
          if (workout == null) return SplashText.notFound(item: 'Workout');

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

          Widget getWorkoutExercisesBreakdown(WorkoutSummary summary) {
            final wes = workout.getWorkoutExercisesDoneOrWithDoneSets();

            return Column(
              children: [
                if (wes.isNotEmpty) ...[
                  const CustomDivider(shadow: true),
                  Container(
                    constraints: BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: wes.length,
                      itemBuilder: (BuildContext context, int i) => Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: WorkoutExerciseSummary(workoutExercise: wes[i], bestSet: summary.bestSet),
                      ),
                    ),
                  ),
                ],
              ],
            );
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

          Widget getSharableSection(WorkoutSummary? summary) => Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: summary == null
                        ? []
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            if (workout.getWorkoutCategories().isNotEmpty)
                              Padding(
                                padding: const EdgeInsetsGeometry.only(top: 1),
                                child: Row(children: [
                                  Expanded(
                                    child: Wrap(
                                      children: workout
                                          .getCategories()
                                          .map((c) => PropDisplay(
                                                text: c.displayName,
                                                color: AppHelper.isDarkMode(context) ? darkPropOnCardColor : null,
                                                size: PropDisplaySize.small,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ]),
                              ),
                            getWorkoutExercisesBreakdown(summary),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Logo()]),
                          ],
                  ),
                ),
              );

          return Center(
            child: Column(children: [
              FutureBuilder(
                future: WorkoutModel.getWorkoutSummary(id: workout.id!),
                builder: (context, snapshot) => Container(
                  padding: EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
                  ),
                  child: getSharableSection(snapshot.data),
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button.elevated(
                    icon: Icons.celebration_rounded,
                    text: 'Relive the Glory!',
                    onTap: () => Confetti.launch(context,
                        options: const ConfettiOptions(particleCount: 200, spread: 70, y: 0.8)),
                  ),
                  Button.elevated(icon: Icons.share_rounded, text: 'Share Workout', onTap: shareCard),
                ],
              ),
            ]),
          );
        });
  }
}
