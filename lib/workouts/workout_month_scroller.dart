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
                    textAlign: TextAlign.center,
                    wc.category!.getDisplayName(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    List<Widget> getWorkoutsWidget(List<Workout> workouts) {
      var rnAndCurrentAreSameMonth = currentMonth.year == rn.year && currentMonth.month == rn.month;
      var daysInCurrentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

      List<Widget> widgets = [];

      for (int day = 1; day <= daysInCurrentMonth; day++) {
        var isToday = rnAndCurrentAreSameMonth && rn.day == day;
        var isLastDayInMonth = day == daysInCurrentMonth;

        var workoutsForDay = workouts
            .where((w) => w.date.year == currentMonth.year && w.date.month == currentMonth.month && w.date.day == day)
            .toList();
        workoutsForDay.sort((w1, w2) => w1.date.compareTo(w2.date));

        if (isToday) {
          widgets.insert(
            0,
            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 2,
            ),
          );
        }

        GlobalKey getKey() {
          if (isToday) return todayKey;
          if (isLastDayInMonth) return lastDayInMonthKey;
          return GlobalKey();
        }

        widgets.insert(
          0, // adds to start of list for most recent date at top
          IntrinsicHeight(
            key: getKey(),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getDateNumString(DateTime(rn.year, rn.month, day)),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.shadow,
                ),
                Expanded(
                  flex: 11,
                  child: Row(
                    children: workoutsForDay.isNotEmpty
                        ? workoutsForDay
                            .map<Widget>(
                              (workout) => Expanded(
                                child: InkWell(
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
                                      padding: const EdgeInsets.all(20),
                                      child: workoutsForDay.length == 1
                                          ? Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Workout',
                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      '@ ${workout.getTimeString()}',
                                                      style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                                                    )
                                                  ],
                                                ),
                                                if (workout.workoutCategories != null &&
                                                    workout.workoutCategories!.isNotEmpty)
                                                  getWorkoutCategoriesWidget(
                                                    workout.workoutCategories!,
                                                    WrapAlignment.end,
                                                  ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Workout',
                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      '@ ${workout.getTimeString()}',
                                                      style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                                                    )
                                                  ],
                                                ),
                                                if (workout.workoutCategories != null &&
                                                    workout.workoutCategories!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: getWorkoutCategoriesWidget(
                                                      workout.workoutCategories!,
                                                      WrapAlignment.start,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()
                        : [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
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

    void onAddWorkoutPress() async {
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
      getSectionTitleWithAction(context, 'Workouts', Icons.add, onAddWorkoutPress),
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
                size: 30,
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
                size: 30,
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
