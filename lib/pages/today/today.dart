import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
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

  void onAddWeightTap() async => CommonFunctions.showBottomSheet(
        context,
        const AddBodyWeightForm(),
      ).then((x) => reloadState());

  Widget getWorkoutOverview(Workout workout) {
    var sets = workout.getSets();
    if (sets.isEmpty) return const SizedBox.shrink();

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

    final bestSetName = bestSet.getExercise()?.isCardio() ?? false ? null : bestSet.getExercise()?.getFullName();

    return Column(children: [
      CommonUI.getDefaultDivider(),
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
      if (bestSetName != null) CommonUI.getDefaultDivider(),
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
                    CommonUI.getWeightWithIcon(bestSet),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    CommonUI.getRepsWithIcon(bestSet)
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
        child: CommonUI.getCard(
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(children: [
                  if (w.workoutExercses?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: CommonUI.getCompleteMark(context, w.done),
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
                        '@ ${w.getTimeStr()}',
                        style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                      ),
                    ],
                  ),
                ]),
                const Padding(padding: EdgeInsets.all(5)),
                if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children:
                            w.getCategories().map((c) => CommonUI.getPropDisplay(context, c.displayName)).toList(),
                      ),
                    ),
                  ]),
                getWorkoutOverview(w),
              ],
            ),
          ),
        ),
      );

  Widget getWorkoutsOrPlaceholder(List<Workout>? workouts) {
    if (workouts == null || workouts.isEmpty) {
      return Padding(
        padding: const EdgeInsetsGeometry.all(5),
        child: Column(children: [
          Text(
            'Tap + to get started!',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.shadow,
            ),
          )

          // todo: add suggested workout button here?
        ]),
      );
    }

    workouts.sort((a, b) => a.date.compareTo(b.date)); // sort by date asc
    return SingleChildScrollView(child: Column(children: workouts.map((w) => getWorkoutDisplay(w)).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonUI.getSectionWidgetWithAction(
          context,
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                ),
                const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              ],
            ),
          ),
          ButtonDetails(
            icon: Icons.add_rounded,
            onTap: () => CommonFunctions.onAddWorkoutTap(context, reloadState, date: today),
          ),
        ),
        const FlavourTextCard(),
        Expanded(
          child: FutureBuilder<List<Workout>>(
            future: todaysWorkouts,
            builder: (context, snapshot) => FutureBuilder<Bodyweight?>(
                future: todaysBodyweight,
                builder: (context, bwsnapshot) {
                  return Column(
                    children: [
                      CommonUI.getCard(
                        bwsnapshot.hasData
                            ? Padding(
                                padding: const EdgeInsetsGeometry.only(left: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.monitor_weight_rounded),
                                      const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                                      Text(
                                        bwsnapshot.data!.getWeightDisplay(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                                      Text(
                                        '@ ${bwsnapshot.data!.getTimeString()}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                                      ),
                                    ]),
                                    Row(children: [
                                      // todo: add edit and view all
                                      CommonUI.getDeleteButton(
                                        () => CommonFunctions.showDeleteConfirm(
                                          context,
                                          "bodyweight",
                                          () => BodyweightModel.deleteBodyweight(bwsnapshot.data!.id!),
                                          reloadState,
                                        ),
                                      ),
                                    ]),
                                  ],
                                ))
                            : CommonUI.getPrimaryButton(ButtonDetails(
                                onTap: onAddWeightTap,
                                text: 'Record Bodyweight',
                                icon: Icons.monitor_weight_rounded,
                              )),
                      ),
                      const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                      Expanded(child: getWorkoutsOrPlaceholder(snapshot.data)),
                    ],
                  );
                }),
          ),
        )
      ],
    );
  }
}
