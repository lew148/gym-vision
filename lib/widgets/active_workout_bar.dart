import 'package:flutter/material.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/common_ui.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutBar extends StatefulWidget {
  static const double height = 65;

  const ActiveWorkoutBar({super.key});

  @override
  State<ActiveWorkoutBar> createState() => _ActiveWorkoutBarState();
}

class _ActiveWorkoutBarState extends State<ActiveWorkoutBar> with SingleTickerProviderStateMixin {
  late ActiveWorkoutProvider provider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<ActiveWorkoutProvider>(context, listen: true);
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
              onTap: () => provider.openActiveWorkout(context, workout: snapshot.data),
              onVerticalDragStart: (details) => provider.openActiveWorkout(context, workout: snapshot.data),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _animation.value),
                        child: child,
                      ),
                      child: Icon(Icons.keyboard_arrow_up_rounded, color: Theme.of(context).colorScheme.shadow),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(
                            workout.getWorkoutTitle(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                          CommonUI.getTimeWithIcon(context, workout.date),
                        ]),
                        TimeElapsed(
                          since: workout.date,
                          color: Theme.of(context).colorScheme.primary,
                          labelForNegativeDuration: 'Starts in',
                          useIcon: false,
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
