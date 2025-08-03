import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/workouts/flavour_text_card.dart';
import 'package:gymvision/pages/forms/add_bodyweight_form.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Today extends StatefulWidget {
  const Today({super.key});

  @override
  State<Today> createState() => _TodayState();
}

class _TodayState extends State<Today> {
  late DateTime today;
  late Future<List<Workout>> todaysWorkouts;
  late Future<Bodyweight?> todaysBodyweight;
  late Future<Schedule?> schedule;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    todaysWorkouts = WorkoutModel.getWorkoutsForDay(today);
    todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
    schedule = ScheduleModel.getActiveSchedule(shallow: false);
  }

  reloadState() => setState(() {
        today = DateTime.now();
        todaysWorkouts = WorkoutModel.getWorkoutsForDay(today);
        todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
      });

  void onAddWeightTap() async => showCustomBottomSheet(
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
      CommonUI.getDivider(),
      Container(
        padding: const EdgeInsets.all(5),
        height: 30,
        child: Row(
          children: [
            Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    '${workout.getWorkoutExercises().length.toString()} exercise${workout.getWorkoutExercises().length == 1 ? '' : 's'}',
                  ),
                )),
            CommonUI.getVerticalDivider(context),
            Expanded(
              flex: 4,
              child: Center(child: Text('${sets.length.toString()} sets')),
            ),
            CommonUI.getVerticalDivider(context),
            Expanded(
              flex: 4,
              child: Center(child: Text('${sets.map((s) => s.reps ?? 0).reduce((a, b) => a + b)} reps')),
            ),
          ],
        ),
      ),
      CommonUI.getDivider(),
      if (bestSetName != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Column(children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber[300]),
                  const Padding(padding: EdgeInsets.all(5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bestSetName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Row(children: [
                CommonUI.getWeightWithIcon(bestSet),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                CommonUI.getRepsWithIcon(bestSet)
              ]),
            ]),
          ]),
        ),
    ]);
  }

  Widget getWorkoutDisplay(Workout w) => CommonUI.getCard(
        context,
        Padding(
          padding: const EdgeInsets.all(15),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: CommonUI.getCompleteMark(context, w.isFinished()),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.getWorkoutTitle(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Row(children: [
                            CommonUI.getTimeWithIcon(context, w.date),
                            if (w.endDate != null) ...[
                              const Padding(padding: EdgeInsetsGeometry.all(5)),
                              CommonUI.getTimeElapsedWithIcon(context, timeBetween(w.date, w.endDate!)),
                            ],
                          ]),
                        ],
                      ),
                    ]),
                    GestureDetector(
                      onTap: () => showOptionsMenu(context, [
                        ButtonDetails(
                          onTap: () {
                            Navigator.pop(context);
                            showDeleteConfirm(
                              context,
                              "workout",
                              () => WorkoutModel.deleteWorkout(w.id!),
                              reloadState,
                            );
                          },
                          icon: Icons.delete_rounded,
                          text: 'Delete Workout',
                          style: ButtonDetailsStyle.redIcon,
                        )
                      ]),
                      child: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(2.5)),
                if (w.workoutCategories != null && w.workoutCategories!.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: Wrap(
                        children: w
                            .getCategories()
                            .map((c) => CommonUI.getPropDisplay(
                                  context,
                                  c.displayName,
                                  color: isDarkMode(context) ? darkPropOnCardColor : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ]),
                getWorkoutOverview(w),
                const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                Row(children: [
                  CommonUI.getTextButton(ButtonDetails(
                    text: 'Add Notes',
                    icon: Icons.add_rounded,
                    style: ButtonDetailsStyle(iconSize: 20),
                    onTap: () => null,
                  )),
                  const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
                  CommonUI.getTextButton(ButtonDetails(
                    text: 'Add Progress Pic',
                    icon: Icons.add_rounded,
                    style: ButtonDetailsStyle(iconSize: 20),
                    onTap: () => null,
                  )),
                ]),
              ],
            ),
          ),
        ),
      );

  Widget getWorkoutsOrPlaceholder(List<Workout>? workouts) {
    if (workouts == null || workouts.isEmpty) {
      return FutureBuilder(
          future: schedule,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsetsGeometry.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_gymnastics_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
                    const Text(
                      'Ready to crush your goals?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Tap + above to begin a workout!',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                      textAlign: TextAlign.center,
                    ),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
                    Text(
                      'OR',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                      textAlign: TextAlign.center,
                    ),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
                    CommonUI.getElevatedPrimaryButton(ButtonDetails(
                      icon: Icons.calendar_month_rounded,
                      text: 'Create a Schedule',
                      onTap: () => Provider.of<NavigationProvider>(context, listen: false).changeTab(3),
                    )),
                  ],
                ),
              );
            }

            final schedule = snapshot.data!;
            final todayCategories = schedule.getCategoriesForDay(today);
            return todayCategories.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hotel_rounded, size: 30),
                      Text(
                        'Relax! Today is a scheduled Rest Day.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  )
                : Column(children: [
                    CommonUI.getCard(
                      context,
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => onAddWorkoutTap(
                          context,
                          reloadState,
                          date: today,
                          categories: todayCategories,
                        ),
                        child: Padding(
                          padding: const EdgeInsetsGeometry.all(10),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text(
                                  'Scheduled for Today',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: todayCategories
                                      .map(
                                        (c) => CommonUI.getPropDisplay(
                                          context,
                                          c.displayName,
                                          color: isDarkMode(context) ? darkPropOnCardColor : null,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ]),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ]),
                        ),
                      ),
                    ),
                  ]);
          });
    }

    workouts.sort((a, b) => a.date.compareTo(b.date)); // sort by date asc
    return SingleChildScrollView(child: Column(children: workouts.map((w) => getWorkoutDisplay(w)).toList()));
  }

  String getTodayTotalCalsString(List<Workout> workouts) {
    var totalCals = 0;

    // todo: make this more performant

    for (int i = 0; i < workouts.length; i++) {
      final workout = workouts[i];
      if (workout.workoutExercises == null) continue;

      for (int j = 0; j < workout.workoutExercises!.length; j++) {
        final we = workout.workoutExercises![j];
        if (we.workoutSets == null) continue;

        for (int k = 0; k < we.workoutSets!.length; k++) {
          final set = we.workoutSets![k];
          if (!set.hasCalsBurned()) continue;
          totalCals += set.calsBurned!;
        }
      }
    }

    return totalCals.toString();
  }

  Widget getCalsAndBodyweightRow(List<Workout>? workouts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: CommonUI.getCard(
              context,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department_rounded, color: Colors.red[300]!),
                          Text(
                            '~${getTodayTotalCalsString(workouts ?? [])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                      Text(
                        'kcals',
                        style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsetsGeometry.all(2.5)),
          Expanded(
            flex: 6,
            child: CommonUI.getCard(
              context,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsGeometry.all(15),
                    child: FutureBuilder<Bodyweight?>(
                        future: todaysBodyweight,
                        builder: (context, bwsnapshot) {
                          if (!bwsnapshot.hasData) {
                            return CommonUI.getTextButton(ButtonDetails(
                              onTap: onAddWeightTap,
                              text: 'Bodyweight',
                              icon: Icons.monitor_weight_rounded,
                            ));
                          }

                          return GestureDetector(
                            onTap: () => showDeleteConfirm(
                              context,
                              "bodyweight",
                              () => BodyweightModel.deleteBodyweight(bwsnapshot.data!.id!),
                              reloadState,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.monitor_weight_rounded, color: Theme.of(context).colorScheme.primary),
                                    const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                                    Text(
                                      bwsnapshot.data!.getWeightDisplay(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '@ ${bwsnapshot.data!.getTimeString()}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: CommonUI.getSectionWidgetWithAction(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(today),
                  style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                ),
                const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              ],
            ),
            ButtonDetails(
              icon: Icons.add_rounded,
              onTap: () => onAddWorkoutTap(context, reloadState, date: today),
            ),
          ),
        ),
        const FlavourTextCard(),
        Expanded(
          child: FutureBuilder<List<Workout>>(
              future: todaysWorkouts,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                return Column(
                  children: [
                    SizedBox(height: 100, child: getCalsAndBodyweightRow(snapshot.data)),
                    Expanded(child: getWorkoutsOrPlaceholder(snapshot.data)),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
