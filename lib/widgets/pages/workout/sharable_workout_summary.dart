import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/custom_vertical_divider.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
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
          // text: 'My music stats 🎧 via #StatsStyle',
        ));
      } catch (e) {
        debugPrint('Error sharing: $e');
      }
    }

    return Center(
      child: Column(children: [
        SplashText(title: 'Workout Summary'),
        const Padding(padding: EdgeInsets.all(5)),
        FutureBuilder(
          future: WorkoutModel.getWorkoutSummary(id: workout.id!),
          builder: (context, snapshot) {
            final summary = snapshot.data;

            return Screenshot(
              controller: screenshotController,
              child: Container(
                constraints: BoxConstraints(maxHeight: 560),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: BoxBorder.all(color: Theme.of(context).colorScheme.shadow),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: !snapshot.hasData
                    ? ShimmerLoad()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
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
                              ]),
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
                                              color:
                                                  AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ]),
                            ),
                          summary == null || summary.totalExercises == 0
                              ? const SizedBox.shrink()
                              : Column(children: [
                                  if (summary.bestSet != null && summary.bestSetExercise != null)
                                    Padding(
                                      padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                                      child: CustomCard(
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
                                    ),
                                  const CustomDivider(shadow: true),
                                  Container(
                                    margin: const EdgeInsetsGeometry.only(top: 5),
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
                                ]),
                        ],
                      ),
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.all(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Button.elevated(
              icon: Icons.celebration_rounded,
              text: 'Relive the glory!',
              onTap: () =>
                  Confetti.launch(context, options: const ConfettiOptions(particleCount: 200, spread: 70, y: 0.8)),
            ),
            // const Padding(padding: EdgeInsets.all(20)),
            Button.elevated(icon: Icons.share_rounded, text: 'Share Workout', onTap: shareCard),
          ],
        ),
      ]),
    );
  }
}
