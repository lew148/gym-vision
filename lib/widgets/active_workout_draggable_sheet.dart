import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/workout_helper.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/widgets/components/animated/pulsing_dot.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutDraggableSheet extends StatelessWidget {
  static const double height = 65; // used for padding behind sheet

  const ActiveWorkoutDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasTriggeredSwipeUp = false;

    return Consumer<ActiveWorkoutProvider>(
      builder: (context, activeWorkoutProvider, child) {
        return FutureBuilder(
          future: activeWorkoutProvider.activeWorkoutFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final workout = snapshot.data!;

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                margin: EdgeInsets.all(5),
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(largeBorderRadius)),
                  border: Border.all(color: Theme.of(context).colorScheme.shadow, width: .5),
                  boxShadow: [BoxShadow(blurRadius: smallBorderRadius, color: Theme.of(context).colorScheme.shadow)],
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => WorkoutHelper.openWorkoutView(context, workout.id!),
                  onVerticalDragUpdate: (details) {
                    // only react if user drags upward
                    if (!hasTriggeredSwipeUp && details.delta.dy < 0) {
                      hasTriggeredSwipeUp = true;
                      WorkoutHelper.openWorkoutView(context, workout.id!);
                    }
                  },
                  onVerticalDragEnd: (_) {
                    hasTriggeredSwipeUp = false;
                  },
                  onVerticalDragCancel: () {
                    hasTriggeredSwipeUp = false;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !DateTimeHelper.isToday(workout.date)
                                    ? '${DateTimeHelper.getDateOrDayStr(workout.date)}\'s Workout'
                                    : workout.getWorkoutTitle(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              StatDisplay.time(workout.date),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!DateTimeHelper.isInFuture(workout.date))
                                Padding(
                                  padding: EdgeInsetsGeometry.only(bottom: 5),
                                  child: PulsingDot.active(),
                                ),
                              TimeElapsed(
                                since: workout.date,
                                color: Theme.of(context).colorScheme.primary,
                                labelForNegativeDuration: 'Starts in',
                                bold: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
