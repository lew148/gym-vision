import 'package:flutter/material.dart';

import '../db/classes/workout.dart';
import '../db/helpers/workouts_helper.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final String workoutDateString;
  const WorkoutView(
      {super.key, required this.workoutId, required this.workoutDateString});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  reloadState() => setState(() {});

  void onAddExerciseClick() => null;

  @override
  Widget build(BuildContext context) {
    final Future<Workout> workout =
        WorkoutsHelper().getWorkout(widget.workoutId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutDateString),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 3),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAddExerciseClick,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'Add Exercise',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          FutureBuilder<Workout>(
            future: workout,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }

              return Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text(snapshot.data!.id.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}
