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
  static const double height = 65;

  const ActiveWorkoutDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.1,
        minChildSize: 0.1,
        maxChildSize: 0.5,
        snapSizes: const [0.1, 0.5],
        snap: true,
        builder: (context, scrollController) {
          return Container(
            height: ActiveWorkoutDraggableSheet.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Theme.of(context).colorScheme.shadow)],
            ),
            child: Consumer<ActiveWorkoutProvider>(builder: (context, activeWorkoutProvider, child) {
              return FutureBuilder(
                future: activeWorkoutProvider.activeWorkoutFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final workout = snapshot.data!;

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => openWorkoutView(context, workout.id!),
                    onVerticalDragStart: (details) => openWorkoutView(context, workout.id!),
                    child: Column(
                      children: [
                        const DragHandle(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
                                  TextWithIcon.time(workout.date),
                                ],
                              ),
                              TimeElapsed(
                                since: workout.date,
                                color: Theme.of(context).colorScheme.primary,
                                labelForNegativeDuration: 'Starts in',
                                useIcon: false,
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          );
        });
  }
}
