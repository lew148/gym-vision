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
import 'package:gymvision/widgets/pages/workouts/flavour_text_card.dart';
import 'package:gymvision/widgets/forms/add_bodyweight_form.dart';
import 'package:gymvision/widgets/common/common_ui.dart';
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
    todaysWorkouts = WorkoutModel.getWorkoutsForDay(today, withSummary: true);
    todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
    schedule = ScheduleModel.getActiveSchedule(withItems: true);
  }

  reloadState() => setState(() {
        today = DateTime.now();
        todaysWorkouts = WorkoutModel.getWorkoutsForDay(today, withSummary: true);
        todaysBodyweight = BodyweightModel.getBodyweightForDay(today);
      });

  void onAddWeightTap() async => showCloseableBottomSheet(
        context,
        const AddBodyWeightForm(),
      ).then((x) => reloadState());

  Widget getWorkoutSummary(WorkoutSummary? summary) => summary == null || summary.totalExercises == 0
      ? const SizedBox.shrink()
      : Column(children: [
          CommonUI.getDivider(),
          Container(
            padding: const EdgeInsets.all(5),
            height: 30,
            child: Row(
              children: [
                Expanded(flex: 4, child: Center(child: Text(summary.getTotalExercisesString()))),
                CommonUI.getVerticalDivider(context),
                Expanded(flex: 4, child: Center(child: Text(summary.getTotalSetsString()))),
                CommonUI.getVerticalDivider(context),
                Expanded(flex: 4, child: Center(child: Text(summary.getTotalRepsString()))),
              ],
            ),
          ),
          CommonUI.getDivider(),
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
                    CommonUI.getWeightWithIcon(summary.bestSet!),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    CommonUI.getRepsWithIcon(summary.bestSet!)
                  ]),
                ]),
              ]),
            ),
        ]);

  Widget getWorkoutDisplay(Workout workout) => CommonUI.getCard(
        context,
        Padding(
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
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: CommonUI.getCompleteMark(context, workout.isFinished()),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.getWorkoutTitle(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Row(children: [
                            CommonUI.getTimeWithIcon(context, workout.date, dtEnd: workout.endDate),
                            if (workout.isFinished()) ...[
                              const Padding(padding: EdgeInsetsGeometry.all(5)),
                              CommonUI.getTimeElapsedWithIcon(context, workout.getDuration()),
                            ],
                          ]),
                        ],
                      ),
                    ]),
                    GestureDetector(
                      onTap: () => showOptionsMenu(context, [
                        ButtonDetails(
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
                        ),
                        ButtonDetails(
                          onTap: () {
                            Navigator.pop(context);
                            showDeleteConfirm(
                              context,
                              "workout",
                              () => WorkoutModel.delete(workout.id!),
                              reloadState,
                            );
                          },
                          icon: Icons.delete_rounded,
                          text: 'Delete Workout',
                          style: ButtonDetailsStyle.redIcon,
                        ),
                      ]),
                      child: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(2.5)),
                if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: Wrap(
                        children: workout
                            .getCategories()
                            .map((c) => CommonUI.getPropDisplay(
                                  context,
                                  c.displayName,
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
                      child: CommonUI.getTextButton(ButtonDetails(
                        text: 'Add Note',
                        icon: Icons.add_rounded,
                        style: ButtonDetailsStyle(iconSize: 20),
                        onTap: () => openWorkoutView(context, workout.id!, autofocusNotes: true),
                      )),
                    ),
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

  Widget getPlaceholderSplashText() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_gymnastics_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
          const Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Text(
              'Ready to crush your goals?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget getScheduledDaySplashText() => Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You scheduled it. Let's do it!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Your workout today is...",
              style: TextStyle(color: Theme.of(context).colorScheme.shadow),
              textAlign: TextAlign.center,
            ),
          ],
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
                      getPlaceholderSplashText(),
                      CommonUI.getElevatedPrimaryButton(ButtonDetails(
                        icon: Icons.add_rounded,
                        text: 'Start a workout',
                        onTap: () => onAddWorkoutTap(context, reloadState, date: today),
                      )),
                      Padding(
                        padding: const EdgeInsetsGeometry.all(5),
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CommonUI.getElevatedPrimaryButton(ButtonDetails(
                        icon: Icons.calendar_month_rounded,
                        text: 'Create a Schedule',
                        onTap: () => Provider.of<NavigationProvider>(context, listen: false).changeTab(3),
                      )),
                    ]);
                  }

                  final schedule = snapshot.data!;
                  final todayCategories = schedule.getCategoriesForDay(today);
                  return todayCategories.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
                            const Text('Relax and take a breath...',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                              'Today is a scheduled rest day',
                              style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Column(children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            children:
                                todayCategories.map((c) => CommonUI.getBigPropDisplay(context, c.displayName)).toList(),
                          ),
                          getScheduledDaySplashText(),
                          CommonUI.getElevatedPrimaryButton(ButtonDetails(
                            icon: Icons.add_rounded,
                            text: 'Start scheduled workout',
                            onTap: () => onAddWorkoutTap(
                              context,
                              reloadState,
                              date: today,
                              categories: todayCategories,
                            ),
                          )),
                        ]);
                }),
          ),
        ],
      );

  Widget getWorkoutsOrPlaceholder(List<Workout>? workouts) {
    if (workouts == null || workouts.isEmpty) return getPlaceholder();
    workouts.sort((a, b) => a.date.compareTo(b.date)); // sort by date asc
    return SingleChildScrollView(child: Column(children: workouts.map((w) => getWorkoutDisplay(w)).toList()));
  }

  String getTodayTotalCalsString(List<Workout>? workouts) =>
      workouts == null ? '' : workouts.map((w) => w.summary).map((s) => s?.totalCalsBurned ?? 0).sum.toString();

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
                            '~${getTodayTotalCalsString(workouts)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonUI.getTextButton(ButtonDetails(
                                  onTap: onAddWeightTap,
                                  text: 'Add BW',
                                  icon: Icons.monitor_weight_rounded,
                                )),
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
