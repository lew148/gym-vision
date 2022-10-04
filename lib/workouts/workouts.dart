import 'package:flutter/material.dart';
import 'package:gymvision/workouts/workout_view.dart';

import '../db/classes/workout.dart';
import '../db/helpers/workouts_helper.dart';

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
          await WorkoutsHelper().deleteWorkout(workoutId);
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
          const Text("Are you sure you would like to delete this W0orkout?"),
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
                          workoutDateString: workout.getDateString(),
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
                      Text(
                        workout.getDateString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (workout.categoryStrings != null &&
                          workout.categoryStrings!.isNotEmpty)
                        getWorkoutCategoryStringsWidget(
                            workout.categoryStrings!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget getWorkoutCategoryStringsWidget(List<String> categoryStrings) {
    return Text('lol');
  }

  void onAddWorkoutPress() async {
    try {
      final now = DateTime.now();
      final newWorkoutId =
          await WorkoutsHelper.insertWorkout(Workout(date: now));

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkoutView(
            workoutId: newWorkoutId,
          ),
        ),
      );
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add workout: $ex')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<Workout>> workouts = WorkoutsHelper().getWorkouts();

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 25,
                  ),
                ),
                onPressed: onAddWorkoutPress,
                child: const Icon(
                  Icons.add,
                  size: 35,
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
