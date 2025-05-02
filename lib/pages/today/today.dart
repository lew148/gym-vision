import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/workouts/flavour_text_card.dart';
import 'package:gymvision/pages/forms/add_bodyweight_form.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:intl/intl.dart';

class Today extends StatefulWidget {
  const Today({super.key});

  @override
  State<Today> createState() => _TodayState();
}

class _TodayState extends State<Today> {
  late DateTime today;
  late Future<List<Workout>> todaysWorkouts;
  late Future<Bodyweight?> todaysBodyweight;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    todaysWorkouts = WorkoutModel.getWorkoutsForDay(today);
    todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
  }

  reloadState() => setState(() {
        today = DateTime.now();
        todaysWorkouts = WorkoutModel.getWorkoutsForDay(today);
        todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
      });

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
        child: CommonUi.getCard(
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CommonUi.getCompleteMark(w.done),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.getWorkoutTitle(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          w.getTimeStr(),
                          style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(10)),
                if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children:
                            w.getCategories().map((c) => CommonUi.getPropDisplay(context, c.displayName)).toList(),
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

  List<Widget> getWorkoutsOrPlaceholder(List<Workout>? workouts) {
    if (workouts == null || workouts.isEmpty) {
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
            const Padding(padding: EdgeInsets.all(5)),
            Row(children: [
              Text(
                'Tap + to record a new workout',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ),
            ]),

            // todo: add suggested workout button here?
          ]),
        ),
      ];
    }

    workouts.sort((a, b) => a.date.compareTo(b.date)); // sort by date asc
    return workouts.map((w) => getWorkoutDisplay(w)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
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
                          return CommonUi.getPrimaryButton(
                            ButtonDetails(
                              onTap: onAddWeightTap,
                              text: 'Add Bodyweight',
                              icon: Icons.monitor_weight_rounded,
                            ),
                          );
                        }

                        return CommonUi.getPrimaryButton(
                          ButtonDetails(
                            onLongTap: () => CommonFunctions.showDeleteConfirm(
                              context,
                              "bodyweight",
                              () => BodyweightModel.deleteBodyweight(snapshot.data!.id!),
                              reloadState,
                            ),
                            text: snapshot.data!.getWeightDisplay(),
                            icon: Icons.monitor_weight_rounded,
                          ),
                        );
                      }),
                ],
              ),
            ),
            const FlavourTextCard(),
            CommonUi.getSectionTitleWithAction(
              context,
              'Workouts',
              ButtonDetails(
                icon: Icons.add,
                onTap: () => CommonFunctions.onAddWorkoutTap(context, reloadState, date: today),
              ),
            ),
            const Divider(thickness: 0.25),
            Expanded(
              child: FutureBuilder<List<Workout>>(
                future: todaysWorkouts,
                builder: (context, snapshot) =>
                    SingleChildScrollView(child: Column(children: getWorkoutsOrPlaceholder(snapshot.data))),
              ),
            )
          ],
        ));
  }
}
