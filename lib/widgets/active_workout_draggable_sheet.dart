import 'package:flutter/material.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/animated/pulsing_dot.dart';
import 'package:gymvision/widgets/components/stateless/drag_handle.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutDraggableSheet extends StatelessWidget {
  static const double height = 85; // used for padding behind sheet

  const ActiveWorkoutDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasTriggeredSwipeUp = false;

    return Consumer<ActiveWorkoutProvider>(builder: (context, activeWorkoutProvider, child) {
      return FutureBuilder(
          future: activeWorkoutProvider.activeWorkoutFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final workout = snapshot.data!;

            return DraggableScrollableSheet(
                initialChildSize: 0.12,
                minChildSize: 0.12,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Theme.of(context).colorScheme.shadow)],
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => openWorkoutView(context, workout.id!),
                      onVerticalDragUpdate: (details) {
                        // only react if user drags upward
                        if (!hasTriggeredSwipeUp && details.delta.dy < 0) {
                          hasTriggeredSwipeUp = true;
                          openWorkoutView(context, workout.id!);
                        }
                      },
                      onVerticalDragEnd: (_) {
                        hasTriggeredSwipeUp = false;
                      },
                      onVerticalDragCancel: () {
                        hasTriggeredSwipeUp = false;
                      },
                      child: Column(
                        children: [
                          const DragHandle(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  if (!DateTimeHelper.isInFuture(workout.date))
                                    const Padding(
                                      padding: EdgeInsetsGeometry.only(right: 8),
                                      child: PulsingDot(),
                                    ),
                                  Text(
                                    !DateTimeHelper.isToday(workout.date)
                                        ? DateTimeHelper.getDateOrDayStr(workout.date)
                                        : workout.getWorkoutTitle(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                TextWithIcon.time(workout.date),
                                TimeElapsed(
                                  since: workout.date,
                                  color: Theme.of(context).colorScheme.primary,
                                  labelForNegativeDuration: 'Starts in',
                                  bold: true,
                                ),
                              ],),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          });
    });
  }
}
