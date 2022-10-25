import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_category.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:gymvision/workouts/workout_view.dart';

import '../db/classes/workout.dart';
import '../db/helpers/workouts_helper.dart';
import 'flavour_text_card.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  reloadState() => setState(() {});

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
                content: Text('Failed to delete Workout: ${ex.toString()}')),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete Workout?"),
      content:
          const Text("Are you sure you would like to delete this Workout?"),
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

  Widget getWorkoutWidget(Workout workout) => Row(
        children: [
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutView(
                          workoutId: workout.id!,
                        ),
                      ),
                    )
                    .then((value) => setState(() {})),
                onLongPress: () => showDeleteWorkoutConfirm(workout.id!),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.getDateString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '@ ${workout.getTimeString()}',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.shadow),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      if (workout.workoutCategories != null &&
                          workout.workoutCategories!.isNotEmpty)
                        getWorkoutCategoriesWidget(workout.workoutCategories!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories) {
    return Expanded(
      child: Wrap(
        alignment: WrapAlignment.end,
        children: workoutCategories
            .map(
              (wc) => Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.75,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  wc.category!.getDisplayName(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void onAddWorkoutPress() async {
    try {
      final newWorkoutId =
          await WorkoutsHelper.insertWorkout(Workout(date: DateTime.now()));

      if (!mounted) return;
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => WorkoutView(
                workoutId: newWorkoutId,
              ),
            ),
          )
          .then((value) => reloadState());
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add workout: $ex')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<Workout>> workouts = WorkoutsHelper.getWorkouts();

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // flavour text
          const FlavourTextCard(),
          const Padding(padding: EdgeInsets.all(5)),

          // workouts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getSectionTitle(context, 'Workouts'),
              OutlinedButton(
                onPressed: onAddWorkoutPress,
                child: const Icon(
                  Icons.add,
                  size: 25,
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: FutureBuilder<List<Workout>>(
                  future: workouts,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('Loading...'),
                      );
                    }

                    if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No Workouts here :('),
                      );
                    }

                    return Column(
                      children: snapshot.data!
                          .map<Widget>((c) => getWorkoutWidget(c))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
