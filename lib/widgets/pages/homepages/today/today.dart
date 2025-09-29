import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/workout_summary.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/flavour_text_card.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/custom_vertical_divider.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/forms/add_bodyweight_form.dart';
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
  late Future<Bodyweight?> todaysBodyweight;
  late Future<Schedule?> schedule;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
    schedule = ScheduleModel.getActiveSchedule(withItems: true);
  }

  reloadState() => setState(() {
        today = DateTime.now();
        todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
      });

  void onAddWeightTap() async => showCloseableBottomSheet(
        context,
        AddBodyWeightForm(),
      ).then((x) => reloadState());

  Widget getWorkoutSummary(WorkoutSummary? summary) => summary == null || summary.totalExercises == 0
      ? const SizedBox.shrink()
      : Column(children: [
          const CustomDivider(shadow: true),
          Container(
            padding: const EdgeInsets.all(5),
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: summary.totalReps + summary.totalSets == 0
                  ? [
                      Text(summary.getTotalExercisesString()),
                    ]
                  : [
                      Expanded(flex: 4, child: Center(child: Text(summary.getTotalExercisesString()))),
                      const CustomVerticalDivider(),
                      Expanded(flex: 4, child: Center(child: Text(summary.getTotalSetsString()))),
                      const CustomVerticalDivider(),
                      Expanded(flex: 4, child: Center(child: Text(summary.getTotalRepsString()))),
                    ],
            ),
          ),
          const CustomDivider(shadow: true),
          if (summary.bestSet != null && summary.bestSetExercise != null)
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
                            summary.bestSetExercise!.getFullName(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(children: [
                    TextWithIcon.weight(summary.bestSet!.weight),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    TextWithIcon.reps(summary.bestSet!.reps),
                  ]),
                ]),
              ]),
            ),
        ]);

  Widget getWorkoutDisplay(Workout workout) => CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => openWorkoutView(context, workout.id!, reloadState: reloadState),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(
                        workout.isFinished() ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: workout.isFinished() ? Theme.of(context).colorScheme.primary : Colors.grey,
                        size: 22,
                      ),
                      const Padding(padding: EdgeInsetsGeometry.all(5)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.getWorkoutTitle(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Row(children: [
                            TextWithIcon.time(workout.date, dtEnd: workout.endDate),
                            if (workout.isFinished()) ...[
                              const Padding(padding: EdgeInsetsGeometry.all(5)),
                              TextWithIcon.timeElapsed(workout.getDuration()),
                            ],
                          ]),
                        ],
                      ),
                    ]),
                    OptionsMenu(buttons: [
                      Button(
                        onTap: () async {
                          Navigator.pop(context);

                          try {
                            final exportString = await WorkoutModel.getWorkoutExportString(workout.id!);
                            if (exportString == null) throw Exception();
                            await Clipboard.setData(ClipboardData(text: exportString));
                            if (mounted) showSnackBar(context, 'Workout copied to clipboard!');
                          } catch (ex) {
                            if (mounted) showSnackBar(context, 'Failed to export workout.');
                          }
                        },
                        icon: Icons.share_rounded,
                        text: 'Export Workout',
                        style: ButtonCustomStyle.primaryIcon(),
                      ),
                      Button(
                        onTap: () {
                          Navigator.pop(context);
                          showDeleteConfirm(
                            context,
                            "workout",
                            () async => deleteWorkout(context, workout.id!),
                            reloadState,
                          );
                        },
                        icon: Icons.delete_rounded,
                        text: 'Delete Workout',
                        style: ButtonCustomStyle.redIcon(),
                      ),
                    ]),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(2.5)),
                if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: Wrap(
                        children: workout
                            .getCategories()
                            .map((c) => PropDisplay(
                                  text: c.displayName,
                                  color: AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ]),
                getWorkoutSummary(workout.summary),
                Row(children: [
                  if (workout.summary?.note == null)
                    Padding(
                      padding: const EdgeInsetsGeometry.only(right: 5),
                      child: Button(
                        text: 'Add Note',
                        icon: Icons.add_rounded,
                        onTap: () => openWorkoutView(context, workout.id!, autofocusNotes: true),
                      ),
                    ),
                  Button(
                    text: 'Add Progress Pic',
                    icon: Icons.add_rounded,
                    onTap: () => null,
                  ),
                ]),
              ],
            ),
          ),
        ),
      );

  Widget getPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 30),
            child: FutureBuilder(
                future: schedule,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(children: [
                      const SplashText(
                        icon: Icons.sports_gymnastics_rounded,
                        title: 'Ready to crush your goals?',
                        description: 'One step closer to greatness!',
                      ),
                      Button(
                        icon: Icons.add_rounded,
                        text: 'Start a workout',
                        onTap: () => onAddWorkoutTap(context, reloadState, date: today),
                      ),
                      Padding(
                        padding: const EdgeInsetsGeometry.all(5),
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Button(
                        icon: Icons.calendar_month_rounded,
                        text: 'Create a Schedule',
                        onTap: () => Provider.of<NavigationProvider>(context, listen: false).changeTab(3),
                      ),
                    ]);
                  }

                  final schedule = snapshot.data!;
                  final todayCategories = schedule.getCategoriesForDay(today);
                  return todayCategories.isEmpty
                      ? const SplashText(
                          icon: Icons.hotel_rounded,
                          title: 'Relax and take a breath...',
                          description: 'Today is a scheduled rest day',
                        )
                      : Column(children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: todayCategories
                                .map((c) => PropDisplay(
                                      text: c.displayName,
                                      size: PropDisplaySize.large,
                                    ))
                                .toList(),
                          ),
                          const SplashText(
                            title: "You scheduled it. Let's do it!",
                            description: 'Jump straight into your scheduled workout',
                          ),
                          Button(
                            icon: Icons.add_rounded,
                            text: 'Start scheduled workout',
                            onTap: () => onAddWorkoutTap(
                              context,
                              reloadState,
                              date: today,
                              categories: todayCategories,
                            ),
                            elevated: true,
                          ),
                        ]);
                }),
          ),
        ],
      );

  Widget getWorkoutsOrPlaceholder(List<Workout>? workouts) {
    if (workouts == null || workouts.isEmpty) return getPlaceholder();
    workouts.sort((a, b) => a.date.compareTo(b.date)); // sort by date asc
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SingleChildScrollView(
          child: Column(children: [
        ...workouts.map((w) => getWorkoutDisplay(w)),
        const ScrollBottomPadding(),
      ])),
    );
  }

  String getTodayTotalCalsString(List<Workout>? workouts) =>
      workouts == null ? '' : workouts.map((w) => w.summary).map((s) => s?.totalCalsBurned ?? 0).sum.toString();

  Widget getCalsAndBodyweightRow(List<Workout>? workouts) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: CustomCard(
              child: Column(
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
                            '~${getTodayTotalCalsString(workouts)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          )
                        ],
                      ),
                      Text('kcals', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsetsGeometry.all(2.5)),
          Expanded(
            flex: 6,
            child: CustomCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsGeometry.all(15),
                    child: FutureBuilder<Bodyweight?>(
                        future: todaysBodyweight,
                        builder: (context, bwsnapshot) {
                          if (!bwsnapshot.hasData) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Button(
                                  onTap: onAddWeightTap,
                                  text: 'Add BW',
                                  icon: Icons.monitor_weight_rounded,
                                ),
                              ],
                            );
                          }

                          return GestureDetector(
                            onTap: () => showDeleteConfirm(
                              context,
                              'bodyweight',
                              () => BodyweightModel.delete(bwsnapshot.data!.id!),
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
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
          child: Header(
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(today),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              ],
            ),
            actions: [
              Button(
                icon: Icons.add_rounded,
                style: ButtonCustomStyle.noPadding(),
                onTap: () => onAddWorkoutTap(context, reloadState, date: today),
              ),
            ],
          ),
        ),
        const FlavourTextCard(),
        Expanded(
          child: Consumer<ActiveWorkoutProvider>(builder: (context, activeWorkoutProvider, child) {
            return FutureBuilder<List<Workout>>(
                future: WorkoutModel.getWorkoutsForDay(today, withSummary: true), // todo: monitor this performance
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  return Column(
                    children: [
                      SizedBox(height: 100, child: getCalsAndBodyweightRow(snapshot.data)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                          child: getWorkoutsOrPlaceholder(snapshot.data),
                        ),
                      ),
                    ],
                  );
                });
          }),
        ),
      ],
    );
  }
}
