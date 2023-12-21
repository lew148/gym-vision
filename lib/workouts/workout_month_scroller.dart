import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:gymvision/workouts/workout_view.dart';

import '../db/classes/workout.dart';
import '../db/classes/workout_category.dart';
import '../db/helpers/workouts_helper.dart';
import '../globals.dart';

class WorkoutMonthScoller extends StatefulWidget {
  final List<Workout> workouts;
  final Function reloadState;

  const WorkoutMonthScoller({
    super.key,
    required this.workouts,
    required this.reloadState,
  });

  @override
  State<WorkoutMonthScoller> createState() => _WorkoutMonthScollerState();
}

class _WorkoutMonthScollerState extends State<WorkoutMonthScoller> {
  final todayKey = GlobalKey();
  final lastDayInMonthKey = GlobalKey();

  final rn = DateTime.now();
  late DateTime currentMonth;

  void reloadState() => setState(() {
        currentMonth = rn;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Scrollable.ensureVisible(todayKey.currentContext!);
        });
      });

  @override
  void initState() {
    super.initState();
    currentMonth = rn;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(todayKey.currentContext!);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, WrapAlignment alignment) => Expanded(
          child: Wrap(
            alignment: alignment,
            children: workoutCategories.map((wc) => getPropDisplay(context, wc.getDisplayName())).toList(),
          ),
        );

    Widget getInnerWorkoutDisplay(Workout workout) => Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (workout.done && !workout.isInFuture() && (workout.workoutSets?.isNotEmpty ?? true))
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${workout.isInFuture() ? 'Planned ' : ''}Session',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '@ ${workout.getTimeString()}',
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(right: 10)),
              if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                getWorkoutCategoriesWidget(
                  workout.workoutCategories!,
                  WrapAlignment.end,
                ),
            ],
          ),
        );

    Widget getBorderedWorkoutDisplay(Workout workout) => DottedBorder(
          color: Theme.of(context).colorScheme.shadow,
          strokeWidth: workout.isInFuture() ? 0.5 : 0,
          dashPattern: const [6, 6],
          padding: EdgeInsets.zero,
          radius: const Radius.circular(5),
          borderType: BorderType.RRect,
          child: getInnerWorkoutDisplay(workout),
        );

    Widget getWorkoutDisplay(Workout workout) => InkWell(
          onTap: () => Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => WorkoutView(
                    workoutId: workout.id!,
                    reloadParent: widget.reloadState,
                  ),
                ),
              )
              .then((value) => widget.reloadState()),
          child: Card(
            color: Colors.grey[800],
            child: workout.isInFuture() ? getBorderedWorkoutDisplay(workout) : getInnerWorkoutDisplay(workout),
          ),
        );

    void onAddWorkoutButtonTap({DateTime? date}) async {
      try {
        var now = DateTime.now();

        if (date != null) {
          date = DateTime(date.year, date.month, date.day, now.hour, now.minute);
        }

        final newWorkoutId = await WorkoutsHelper.insertWorkout(Workout(date: date ?? now));
        if (!mounted) return;

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => WorkoutView(
                  workoutId: newWorkoutId,
                  reloadParent: widget.reloadState,
                ),
              ),
            )
            .then((value) => widget.reloadState());
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add workout')),
        );
      }
    }

    List<Widget> getWorkoutsWidget(List<Workout> workouts) {
      var rnAndCurrentAreSameMonth = currentMonth.year == rn.year && currentMonth.month == rn.month;
      var daysInCurrentMonth = getDaysInMonth(currentMonth.year, currentMonth.month);

      List<Widget> widgets = [];

      for (int day = 1; day <= daysInCurrentMonth; day++) {
        var currentDate = DateTime(currentMonth.year, currentMonth.month, day);
        var isToday = rnAndCurrentAreSameMonth && rn.day == day;
        var isLastDayInMonth = day == daysInCurrentMonth;

        var workoutsForDay = workouts
            .where((w) => w.date.year == currentMonth.year && w.date.month == currentMonth.month && w.date.day == day)
            .toList();
        workoutsForDay.sort((w1, w2) => w2.date.compareTo(w1.date));

        GlobalKey getKey() {
          if (isToday) return todayKey;
          if (isLastDayInMonth) return lastDayInMonthKey;
          return GlobalKey();
        }

        if (currentDate.weekday == 1) widgets.insert(0, const Divider(thickness: 0.25));

        widgets.insert(
          0, // adds to start of list for most recent date at top
          IntrinsicHeight(
            key: getKey(),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        getSmallDateDisplay(currentDate),
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                      ),
                      const Padding(padding: EdgeInsets.all(2)),
                    ],
                  ),
                ),
                VerticalDivider(
                  thickness: isToday ? 6 : 1,
                  color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.shadow,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: workoutsForDay.isNotEmpty
                        ? workoutsForDay.map<Widget>((workout) => getWorkoutDisplay(workout)).toList()
                        : [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => onAddWorkoutButtonTap(date: currentDate),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: dateIsInFuture(currentDate) || isToday
                                      ? [
                                          Text(
                                            '-',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.shadow,
                                            ),
                                          ),
                                        ]
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
        );
      }

      return widgets;
    }

    void onArrowTap(int i) {
      setState(() {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + i);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (todayKey.currentContext != null) {
            Scrollable.ensureVisible(todayKey.currentContext!);
          } else if (lastDayInMonthKey.currentContext != null) {
            Scrollable.ensureVisible(lastDayInMonthKey.currentContext!);
          }
        });
      });
    }

    return Column(children: [
      getSectionTitleWithActions(
        context,
        '',
        [
          ActionButton(icon: Icons.today_outlined, onTap: reloadState, text: 'Today'),
          ActionButton(icon: Icons.add_rounded, onTap: onAddWorkoutButtonTap),
        ],
      ),
      const Padding(padding: EdgeInsets.all(2.5)),
      Row(
        children: [
          Expanded(
            flex: 4,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () => onArrowTap(-1),
              icon: const Icon(
                Icons.arrow_left_rounded,
                size: 40,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                getMonthAndYear(currentMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () => onArrowTap(1),
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 40,
              ),
            ),
          ),
        ],
      ),
      const Divider(thickness: 0.25),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: getWorkoutsWidget(widget.workouts),
          ),
        ),
      ),
    ]);
  }
}
