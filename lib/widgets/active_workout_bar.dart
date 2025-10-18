import 'package:flutter/material.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutBar extends StatefulWidget {
  static const double height = 65;

  const ActiveWorkoutBar({super.key});

  @override
  State<ActiveWorkoutBar> createState() => _ActiveWorkoutBarState();
}

class _ActiveWorkoutBarState extends State<ActiveWorkoutBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true, count: 8);

    _animation = Tween<double>(begin: 4, end: -3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ActiveWorkoutBar.height,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _animation.value),
                        child: child,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Theme.of(context).colorScheme.shadow,
                        size: 25,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
