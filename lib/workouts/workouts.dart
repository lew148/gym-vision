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
  final Future<List<Workout>> _workouts = WorkoutsHelper().getWorkouts();

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
                        getWorkoutCategoryStringsWidget(workout.categoryStrings!),
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
      await WorkoutsHelper.insertWorkout(Workout(date: DateTime.now()));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add workout: $ex')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          FutureBuilder<List<Workout>>(
            future: _workouts,
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
        ],
      ),
    );
  }
}
