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
    void showDeleteWorkoutConfirm(int workoutId) {
      Widget cancelButton = TextButton(
        child: const Text("No"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      Widget continueButton = TextButton(
        child: const Text(
          "Yes",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          Navigator.pop(context);

          try {
            await WorkoutsHelper.deleteWorkout(workoutId);
          } catch (ex) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete Workout: ${ex.toString()}'),
              ),
            );
          }

          widget.reloadState();
        },
      );

      AlertDialog alert = AlertDialog(
        title: const Text("Delete Workout?"),
        content: const Text("Are you sure you would like to delete this Workout?"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      showDialog(
        context: context,
        builder: (context) => alert,
      );
    }

    Widget getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, WrapAlignment alignment) {
      workoutCategories.sort((a, b) => a.category!.name.compareTo(b.category!.name));

      return Expanded(
        child: Wrap(
          alignment: alignment,
          children: workoutCategories
              .map(
                (wc) => Container(
                  margin: const EdgeInsets.only(bottom: 5, right: 5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.onBackground),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    wc.category!.getDisplayName(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    Widget getWorkoutDisplay(Workout workout) => InkWell(
          onTap: () => Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => WorkoutView(
                    workoutId: workout.id!,
                  ),
                ),
              )
              .then((value) => widget.reloadState()),
          onLongPress: () => showDeleteWorkoutConfirm(workout.id!),
          child: Card(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${workout.isInFuture() ? 'Planned ' : ''}Workout',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@ ${workout.getTimeString()}',
                          style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    // if (workout.workoutExercises != null && workout.workoutExercises!.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(right: 10),
                    //     child: Icon(
                    //       Icons.check_circle_outline_rounded,
                    //       size: 25,
                    //       color: Colors.green[400],
                    //     ),
                    //   ),
                    if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                      getWorkoutCategoriesWidget(
                        workout.workoutCategories!,
                        WrapAlignment.end,
                      ),
                  ],
                )),
          ),
        );

    List<Widget> getWorkoutsWidget(List<Workout> workouts) {
      var rnAndCurrentAreSameMonth = currentMonth.year == rn.year && currentMonth.month == rn.month;
      var daysInCurrentMonth = getDaysInMonth(currentMonth.year, currentMonth.month);

      List<Widget> widgets = [];

      for (int day = 1; day <= daysInCurrentMonth; day++) {
        var isToday = rnAndCurrentAreSameMonth && rn.day == day;
        var isLastDayInMonth = day == daysInCurrentMonth;

        var workoutsForDay = workouts
            .where((w) => w.date.year == currentMonth.year && w.date.month == currentMonth.month && w.date.day == day)
            .toList();
        workoutsForDay.sort((w1, w2) => w1.date.compareTo(w2.date));

        GlobalKey getKey() {
          if (isToday) return todayKey;
          if (isLastDayInMonth) return lastDayInMonthKey;
          return GlobalKey();
        }

        widgets.insert(0, const Divider());

        widgets.insert(
          0, // adds to start of list for most recent date at top
          IntrinsicHeight(
            key: getKey(),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      getDateNumString(DateTime(rn.year, rn.month, day)),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                VerticalDivider(
                  thickness: isToday ? 6 : 1,
                  color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.shadow,
                ),
                Expanded(
                  flex: 11,
                  child: Column(
                    children: workoutsForDay.isNotEmpty
                        ? workoutsForDay.map<Widget>((workout) => getWorkoutDisplay(workout)).toList()
                        : [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:
                                    dateIsInFuture(DateTime(currentMonth.year, currentMonth.month, day)) || isToday
                                        ? [
                                            Text(
                                              '-',
                                              style: TextStyle(
                                                fontSize: 15,
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
                                              'Rest Day',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.shadow,
                                              ),
                                            ),
                                          ],
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (day == daysInCurrentMonth) widgets.insert(0, const Divider(thickness: 2));
      }

      return widgets;
    }

    void onAddWorkoutButtonTap() async {
      try {
        final newWorkoutId = await WorkoutsHelper.insertWorkout(Workout(date: DateTime.now()));
        if (!mounted) return;

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => WorkoutView(
                  workoutId: newWorkoutId,
                ),
              ),
            )
            .then((value) => widget.reloadState());
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add workout: $ex')),
        );
      }
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
        'Workouts',
        [
          ActionButton(icon: Icons.today_rounded, onTap: reloadState, text: 'Today'),
          ActionButton(icon: Icons.add_rounded, onTap: onAddWorkoutButtonTap),
        ],
      ),
      const Divider(),
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
      const Divider(),
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
