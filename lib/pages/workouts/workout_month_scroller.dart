import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:intl/intl.dart';

class WorkoutMonthScoller extends StatefulWidget {
  final List<Workout> workouts;
  final List<Bodyweight> bodyweights;
  final UserSettings userSettings;
  final Function reloadParent;

  const WorkoutMonthScoller({
    super.key,
    required this.workouts,
    required this.bodyweights,
    required this.userSettings,
    required this.reloadParent,
  });

  @override
  State<WorkoutMonthScoller> createState() => _WorkoutMonthScollerState();
}

class _WorkoutMonthScollerState extends State<WorkoutMonthScoller> {
  final todayKey = GlobalKey();
  final lastDayInMonthKey = GlobalKey();
  final trueDate = DateTime.now();
  late DateTime selectedMonth;
  late Timer timer;

  var right = 0.0;
  var left = 0.0;
  var animationInMotion = false;

  void ensureTodayVisible() => Scrollable.ensureVisible(todayKey.currentContext!,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);

  void reloadState() => setState(() {
        selectedMonth = trueDate;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ensureTodayVisible();
        });
      });

  void timerReload() {
    if (!mounted) return;
    setState(() {
      timer.cancel();
      timer = Timer.periodic(const Duration(seconds: 60), (timer) => timerReload());
    });
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = trueDate;

    final timeToNextMin = Duration(seconds: 60 - trueDate.second);
    timer = Timer.periodic(timeToNextMin, (Timer t) => timerReload());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureTodayVisible();
    });
  }

  Widget getWorkoutDisplay(Workout workout) => InkWell(
        onLongPress: () => CommonFunctions.showDeleteConfirm(
          context,
          "workout",
          () => WorkoutModel.deleteWorkout(workout.id!),
          widget.reloadParent,
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => WorkoutView(
                workoutId: workout.id!,
                reloadParent: widget.reloadParent,
              ),
            ))
            .then((value) => widget.reloadParent()),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (!workout.getIsEmpty())
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CommonUI.getCompleteMark(context, !workout.isInFuture() && workout.done),
                      ),
                    Text(
                      workout.getWorkoutTitle(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ]),
                  Text(
                    workout.getTimeStr(),
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                  ),
                  if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                    SizedBox(
                      width: 250, // hardcoded width to prevent overflow. could break on different screen sizes
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children: workout.workoutCategories!
                            .map((wc) => CommonUI.getPropDisplay(context, wc.getCategoryDisplayName()))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget getBodyweightDisplay(Bodyweight bw) => InkWell(
        onLongPress: () => CommonFunctions.showDeleteConfirm(
          context,
          "bodyweight",
          () => BodyweightModel.deleteBodyweight(bw.id!),
          widget.reloadParent,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${bw.getWeightDisplay()} @ ${bw.getTimeString()}',
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  List<Widget> getWorkoutsWidget(List<Workout> workouts, List<Bodyweight> bws) {
    var selectedMonthIsTrueMonth = selectedMonth.year == trueDate.year && selectedMonth.month == trueDate.month;
    var daysInCurrentMonth = getDaysInMonth(selectedMonth.year, selectedMonth.month);

    List<Widget> widgets = [];

    for (int day = 1; day <= daysInCurrentMonth; day++) {
      var currentDate = DateTime(selectedMonth.year, selectedMonth.month, day);
      var isToday = selectedMonthIsTrueMonth && trueDate.day == day;
      var isLastDayInMonth = day == daysInCurrentMonth;

      var workoutsForDay = workouts
          .where((w) => w.date.year == selectedMonth.year && w.date.month == selectedMonth.month && w.date.day == day)
          .toList();
      workoutsForDay.sort((w1, w2) => w1.date.compareTo(w2.date));

      var bwsForDay = bws
          .where((w) => w.date.year == selectedMonth.year && w.date.month == selectedMonth.month && w.date.day == day)
          .toList();
      bwsForDay.sort((w1, w2) => w2.date.compareTo(w1.date));

      GlobalKey getKey() {
        if (isToday) return todayKey;
        if (isLastDayInMonth) return lastDayInMonthKey;
        return GlobalKey();
      }

      String getDateDisplay(DateTime dt) {
        if (isToday) return "Today";
        // if (currentIsRealMonth && day == realDate.day + 1) return "Tomorrow";
        // if (currentIsRealMonth && day == realDate.day - 1) return "Yesterday";
        // if (selectedMonth.year != trueDate.year) return DateFormat('EEE d MMM yyyy').format(dt);
        // if (!selectedMonthIsTrueMonth) return DateFormat('EEE d MMM').format(dt);
        return DateFormat('EEE d').format(dt);
      }

      widgets.add(
        Column(children: [
          if (isToday || selectedMonthIsTrueMonth && trueDate.day == day + 1)
            const Padding(padding: EdgeInsets.all(2.5)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getDateDisplay(currentDate),
                    textAlign: TextAlign.end,
                    style: isToday
                        ? TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                VerticalDivider(
                  thickness: isToday ? 3 : 0.5,
                  color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.shadow,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: workoutsForDay.isNotEmpty || bwsForDay.isNotEmpty
                        ? [
                            ...workoutsForDay.map<Widget>((workout) => getWorkoutDisplay(workout)),
                            ...bwsForDay.map<Widget>((bw) => getBodyweightDisplay(bw))
                          ]
                        : [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () =>
                                  CommonFunctions.onAddWorkoutTap(context, widget.reloadParent, date: currentDate),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: dateXIsAfterDateY(widget.userSettings.createdAt!, currentDate) ||
                                          dateIsInFuture(currentDate) ||
                                          isToday
                                      ? [CommonUI.getDash()]
                                      : [
                                          Icon(
                                            Icons.hotel_rounded,
                                            color: Theme.of(context).colorScheme.shadow,
                                            size: 20,
                                          ),
                                          const Padding(padding: EdgeInsets.all(5)),
                                          Text(
                                            'Rest',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.shadow,
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
          if (isToday || selectedMonthIsTrueMonth && trueDate.day == day - 1)
            const Padding(padding: EdgeInsets.all(2.5)),
          Divider(
            key: getKey(),
            thickness: 0.1,
            height: 0,
            color: Theme.of(context).colorScheme.shadow,
          ),
        ]),
      );
    }

    return widgets;
  }

  void onArrowTap(int i) {
    setState(() {
      right = i > 0 ? -300 : 300;
      left = i < 0 ? -300 : 300;
      animationInMotion = true;
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + i);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (todayKey.currentContext != null) {
          ensureTodayVisible();
        } else if (lastDayInMonthKey.currentContext != null) {
          Scrollable.ensureVisible(lastDayInMonthKey.currentContext!);
        }
      });
    });
  }

  void rebuildAfterLoad() => WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });

  @override
  Widget build(BuildContext context) {
    const swipeSpeed = 30;

    if (animationInMotion) {
      if (right > swipeSpeed && left < swipeSpeed) {
        right -= swipeSpeed;
        left += swipeSpeed;
        rebuildAfterLoad();
      } else if (right < swipeSpeed && left > swipeSpeed) {
        right += swipeSpeed;
        left -= swipeSpeed;
        rebuildAfterLoad();
      } else {
        right = 0;
        left = 0;
        animationInMotion = false;
        rebuildAfterLoad();
      }
    }

    return GestureDetector(
      onPanUpdate: (details) {
        animationInMotion = false;
        right = right - details.delta.dx;
        left = left + details.delta.dx;
        setState(() {});
      },
      onPanEnd: (details) {
        animationInMotion = true;
        if (right >= MediaQuery.of(context).size.width / 3 || details.velocity.pixelsPerSecond.dx < -500) {
          return onArrowTap(1);
        }

        if (left >= MediaQuery.of(context).size.width / 3 || details.velocity.pixelsPerSecond.dx > 500) {
          return onArrowTap(-1);
        }

        setState(() {});
      },
      child: Stack(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 15,
                  onPressed: () => onArrowTap(-1),
                  icon: const Icon(
                    Icons.arrow_left_rounded,
                    size: 40,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      getMonthAndYear(selectedMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 15,
                  onPressed: () => onArrowTap(1),
                  icon: const Icon(
                    Icons.arrow_right_rounded,
                    size: 40,
                  ),
                ),
                CommonUI.getPrimaryButton(ButtonDetails(icon: Icons.today_outlined, onTap: reloadState)),
              ],
            ),
          ),
          Positioned.fill(
            top: 50,
            right: right,
            left: left,
            child: SingleChildScrollView(
              child: Column(children: getWorkoutsWidget(widget.workouts, widget.bodyweights)),
            ),
          ),
        ],
      ),
    );
  }
}
