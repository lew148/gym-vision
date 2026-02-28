import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/confetti_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/logo.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/workouts/summary/workout_exercise_summary.dart';
import 'package:gymvision/widgets/components/workouts/summary/workout_summary_stats.dart';
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
              await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
            } catch (e) {
              if (context.mounted) ToastHelper.showFailureToast(context, message: 'Failed to share summary!');
            }
          }

          Widget getWorkoutExercisesBreakdown(WorkoutSummary summary) {
            final wes = OrderingHelper.sortByOrder(
              workout.getWorkoutExercisesDoneOrWithDoneSets(),
              workout.exerciseOrder,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (wes.isNotEmpty) ...[
                  const CustomDivider(shadow: true),
                  Container(
                    constraints: BoxConstraints(maxHeight: 500),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: wes.length,
                        itemBuilder: (BuildContext context, int i) => Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: WorkoutExerciseSummary(workoutExercise: wes[i], bestSet: summary.bestSet),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          Widget getSharableSection(WorkoutSummary? summary) => Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: Theme.of(context).colorScheme.surface,
                  ),
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
                                    StatDisplay.date(workout.date),
                                    Row(children: [
                                      StatDisplay.time(workout.date),
                                      if (workout.isFinished()) ...[
                                        const Padding(padding: EdgeInsetsGeometry.all(5)),
                                        StatDisplay.timeElapsed(workout.getDuration()),
                                      ],
                                    ]),
                                  ],
                                ),
                                WorkoutSummaryStats(summary: summary),
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
                                                size: PropDisplaySize.small,
                                                onCard: true,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ]),
                              ),
                            getWorkoutExercisesBreakdown(summary),
                            const Padding(padding: EdgeInsetsGeometry.all(2.5)),
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
                  ),
                  child: getSharableSection(snapshot.data),
                ),
              ),
              const Padding(padding: EdgeInsets.all(2.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button.elevated(
                    icon: Icons.celebration_rounded,
                    text: 'Relive the Glory!',
                    onTap: () => ConfettiHelper.straightUp(context),
                  ),
                  const Padding(padding: EdgeInsetsGeometry.all(5)),
                  Button.elevated(icon: Icons.share_rounded, text: 'Share Workout', onTap: shareCard),
                ],
              ),
            ]),
          );
        });
  }
}
