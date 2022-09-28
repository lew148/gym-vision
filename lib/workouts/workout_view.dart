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

  @override
  Widget build(BuildContext context) {
    final Future<Workout> workout =
        WorkoutsHelper().getWorkout(widget.workoutId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutDateString),
      ),
      body: FutureBuilder<Workout>(
        future: workout,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text(snapshot.data!.id.toString()),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}