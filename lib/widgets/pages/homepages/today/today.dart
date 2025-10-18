import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/widgets/components/flavour_text_card.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/workout_summary_card.dart';
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
  DateTime today() => DateTime.now();
  void reload() => setState(() {});

  void onAddWeightTap() async {
    await showCloseableBottomSheet(context, AddBodyWeightForm(), title: 'Add Bodyweight');
    reload();
  }

  Widget getPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 30),
            child: FutureBuilder(
                future: ScheduleModel.getActiveSchedule(withItems: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(children: [
                      const SplashText(
                        icon: Icons.sports_gymnastics_rounded,
                        title: 'Ready to crush your goals?',
                        description: 'One step closer to greatness!',
                      ),
                      Button.elevated(
                        icon: Icons.add_rounded,
                        text: 'Start a workout',
                        onTap: () async {
                          await addWorkout(context);
                          reload();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsetsGeometry.all(5),
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Button.elevated(
                        icon: Icons.calendar_month_rounded,
                        text: 'Create a Schedule',
                        onTap: () => Provider.of<NavigationProvider>(context, listen: false).changeTab(3),
                      ),
                    ]);
                  }

                  final schedule = snapshot.data!;
                  final todayCategories = schedule.getCategoriesForDay(today());
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
                          Button.elevated(
                            icon: Icons.add_rounded,
                            text: 'Start scheduled workout',
                            onTap: () async {
                              await addWorkout(context, categories: todayCategories);
                              reload();
                            },
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
        ...workouts.map((w) => WorkoutSummaryCard(workout: w, reloadParent: reload)),
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
                        future: BodyweightModel.getBodyweightForDay(today()),
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
                            onTap: () async {
                              await showDeleteConfirm(
                                context,
                                'bodyweight',
                                () => BodyweightModel.delete(bwsnapshot.data!.id!),
                              );

                              reload();
                            },
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
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: Column(
            children: [
              Header(title: DateFormat('EEEE, MMMM d').format(today())),
              Header.large(
                'Today',
                actions: [
                  Button(
                    icon: Icons.add_rounded,
                    onTap: () async {
                      await addWorkout(context);
                      reload();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        const FlavourTextCard(),
        Expanded(
          child: Consumer<ActiveWorkoutProvider>(builder: (context, activeWorkoutProvider, child) {
            return FutureBuilder<List<Workout>>(
                future: WorkoutModel.getWorkoutsForDay(today(), withSummary: true),
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
