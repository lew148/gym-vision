import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/workouts/flavour_text_card.dart';
import 'package:gymvision/pages/forms/add_bodyweight_form.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/pages/ui_helper.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:intl/intl.dart';

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
    final Future<List<Workout>> todaysWorkouts = WorkoutModel.getWorkoutsForDay(today);
    final Future<Bodyweight?> todaysBodyweight = BodyweightModel.getBodyweightForDay(today);

    void onAddWeightTap() async => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddBodyWeightForm(reloadState: reloadState),
              ),
            ],
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        );

    Widget getWorkoutOverview(Workout workout) {
      var sets = workout.getSets();

      if (sets.isEmpty) {
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

      final bestSetName = bestSet.getExercise()?.name;

      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(children: [
                  Text(workout.getWorkoutExercises().length.toString()),
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
        if (bestSetName != null) const Divider(thickness: 0.25),
        if (bestSetName != null)
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
                      bestSetName,
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
              child: Column(
                children: [
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
                          children:
                              w.getCategories().map((c) => UiHelper.getPropDisplay(context, c.displayName)).toList(),
                        ),
                      ),
                  ]),
                  const Divider(thickness: 0.25),
                  getWorkoutOverview(w),
                ],
              ),
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
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 25)),
                  Expanded(
                    child: FutureBuilder<Bodyweight?>(
                        future: todaysBodyweight,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Card(
                              child: InkWell(
                                onTap: onAddWeightTap,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(
                                        Icons.monitor_weight_rounded,
                                        size: 25,
                                      ),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 25,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            child: InkWell(
                              onLongPress: () => UiHelper.showDeleteConfirm(
                                context,
                                () => BodyweightModel.deleteBodyweight(snapshot.data!.id!),
                                reloadState,
                                "bodyweight",
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.monitor_weight_rounded,
                                      size: 25,
                                    ),
                                    const Padding(padding: EdgeInsets.all(5)),
                                    Text(
                                      snapshot.data!.getWeightDisplay(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
            const FlavourTextCard(),
            UiHelper.getSectionTitle(context, 'Activities'),
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
