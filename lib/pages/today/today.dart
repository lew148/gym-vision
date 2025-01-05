import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/helpers/bodyweight_helper.dart';
import 'package:gymvision/globals.dart';
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
    final today = DateTime.now();
    final Future<List<Workout>> todaysWorkouts = WorkoutsHelper.getWorkoutsForDay(today);
    final Future<Bodyweight?> todaysBodyweight = BodyweightHelper.getBodyweightForDay(today);

    // Widget getOverviewDetail()

    Widget getWorkoutOverview(List<WorkoutSet>? sets, int exercisesRecorded) {
      if (sets == null || sets.isEmpty) {
        return Text(
          'Tap to record workout sets',
          style: TextStyle(color: Theme.of(context).colorScheme.shadow),
        );
      }

      var setsGroupedByWeight = groupBy(sets, (s) => s.weight);
      var heaviestWeight = (setsGroupedByWeight.keys.toList()..sort((a, b) => a! < b! ? 1 : 0))[0];
      var bestSets = sets.where((s) => s.weight == heaviestWeight);
      WorkoutSet bestSet;

      if (bestSets.length > 1) {
        var bestSetsGroupedByReps = groupBy(bestSets, (s) => s.reps);
        var highestReps = (bestSetsGroupedByReps.keys.toList()..sort((a, b) => a! < b! ? 1 : 0))[0];
        bestSet = sets.firstWhere((s) => s.weight == heaviestWeight && s.reps == highestReps);
      } else {
        bestSet = sets.firstWhere((s) => s.weight == heaviestWeight);
      }

      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(children: [
                  Text(exercisesRecorded.toString()),
                  const Text(
                    'Exercises',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              Expanded(
                flex: 6,
                child: Column(children: [
                  Text(sets.length.toString()),
                  const Text(
                    'Sets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
            ],
          ),
        ),
        const Divider(thickness: 0.25),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.emoji_events_rounded),
              const Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bestSet.exercise?.name ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.all(2.5)),
                  Row(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: bestSet.hasWeight()
                          ? [
                              const Icon(
                                Icons.fitness_center_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(bestSet.getWeightDisplay()),
                            ]
                          : [dashIcon()],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: bestSet.reps != null && bestSet.reps! > 0
                          ? [
                              const Icon(
                                Icons.repeat_rounded,
                                size: 15,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(bestSet.getRepsDisplay()),
                            ]
                          : [dashIcon()],
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ]);
    }

    Widget getWorkoutDisplay(Workout w) => InkWell(
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
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.check_box_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Workout',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            w.getTimeStr(),
                            style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: CategoryShellHelper.sortCategories(w.workoutCategories!)
                            .map((wc) => getPropDisplay(context, wc.getDisplayName()))
                            .toList(),
                      ),
                    ),
                ]),
                const Divider(thickness: 0.25),
                getWorkoutOverview(
                    w.getRealSets(),
                    w.workoutSets == null || w.workoutSets!.isEmpty
                        ? 0
                        : distinctIntList(w.workoutSets!.map((ws) => ws.exerciseId).toList()).length),
              ]),
            ),
          ),
        );

    List<Widget> getWorkoutsOrPlaceholder(List<Workout> workouts) {
      if (workouts.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              Row(children: [
                Icon(
                  Icons.hotel_rounded,
                  color: Theme.of(context).colorScheme.shadow,
                  size: 25,
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Text(
                  'Resting...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.shadow,
                    fontSize: 20,
                  ),
                ),
              ]),
              const Padding(padding: EdgeInsets.all(2.5)),
              Row(children: [
                Text(
                  'Tap the + to record a workout.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ),
              ]),

              // todo: add suggested workout for today button here?
            ]),
          ),
        ];
      }

      return workouts.map((w) => getWorkoutDisplay(w)).toList();
    }

    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  FutureBuilder<Bodyweight?>(
                      future: todaysBodyweight,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink(); // loading
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(children: [
                              const Icon(Icons.monitor_weight_rounded),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(
                                snapshot.data!.getWeightDisplay(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ]),
                          ),
                        );
                      }),
                ],
              ),
            ),
            const FlavourTextCard(),
            getSectionTitle(context, 'Activities'),
            const Divider(thickness: 0.25),
            FutureBuilder<List<Workout>>(
                future: todaysWorkouts,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink(); // loading
                  }

                  return Expanded(child: Column(children: getWorkoutsOrPlaceholder(snapshot.data!)));
                }),
          ],
        ));
  }
}
