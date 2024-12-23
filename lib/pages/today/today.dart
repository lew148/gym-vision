import 'package:flutter/material.dart';
import 'package:gymvision/helpers/category_shell_helper.dart';
import 'package:gymvision/pages/workouts/flavour_text_card.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:intl/intl.dart';
import '../../db/classes/workout.dart';
import '../../db/helpers/workouts_helper.dart';

class Today extends StatefulWidget {
  final Function({DateTime? date}) onAddWorkoutTap;

  const Today({
    super.key,
    required this.onAddWorkoutTap,
  });

  @override
  State<Today> createState() => _TodayState();
}

class _TodayState extends State<Today> {
  reloadState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Future<List<Workout>> todaysWorkouts = WorkoutsHelper.getWorkoutsForDay(DateTime.now());
    // final Future<Bodyweight> todaysBodyweights = BodyweightHelper.getBodyweightForDay();

    Widget getWorkoutDisplay(Workout w) => Expanded(
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutView(
                      workoutId: w.id!,
                      reloadParent: reloadState,
                    ),
                  ),
                )
                .then((value) => reloadState()),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (w.done)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.check_box_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            ),
                          ),
                        const Text(
                          'Workout',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ]),
                  const Divider(thickness: 0.25),
                  Row(children: [
                    if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty)
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: CategoryShellHelper.sortCategories(w.workoutCategories!)
                              .map((wc) => getPropDisplay(context, wc.getDisplayName()))
                              .toList(),
                        ),
                      ),
                  ]),
                ]),
              ),
            ),
          ),
        );

    return Container(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<Workout>>(
          future: todaysWorkouts,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink(); // loading
            }

            var workouts = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                          ),
                          const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                        ],
                      ),
                    ],
                  ),
                ),
                const FlavourTextCard(),
                getSectionTitle(context, 'Activities'),
                const Divider(thickness: 0.25),
                ...(workouts.map((w) => getWorkoutDisplay(w))),
              ],
            );
          },
        ));
  }
}
