import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/workouts/add_exercise_to_workout_form.dart';

import '../db/classes/workout.dart';
import '../db/helpers/workouts_helper.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final String? workoutDateString;
  const WorkoutView(
      {super.key, required this.workoutId, this.workoutDateString});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  reloadState() => setState(() {});

  void onAddExerciseClick(List<int> existingExerciseIds) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddExerciseToWorkoutForm(
                workoutId: widget.workoutId,
                existingExerciseIds: existingExerciseIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  Widget getSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.shadow,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  void showRemoveExerciseFromWorkoutConfirm(int workoutExerciseId) {
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
          await WorkoutsHelper().removeExerciseFromWorkout(workoutExerciseId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to remove exercise from workout: ${ex.toString()}')),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Exercise from Workout?"),
      content: const Text(
          "Are you sure you would like to remove this exercise from this workout?"),
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

  getWorkoutExercisesWidget(List<WorkoutExercise> workoutExercises) =>
      workoutExercises
          .map(
            (we) => Card(
              child: InkWell(
                onLongPress: () => showRemoveExerciseFromWorkoutConfirm(we.id!),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        we.exercise!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${we.sets} sets'),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    Future<Workout> workout = WorkoutsHelper().getWorkout(widget.workoutId);
    List<int> existingExerciseIds = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutDateString ?? 'New Workout'),
      ),
      body: Column(
        children: [
          getSectionTitle('Categories'),
          const Divider(),
          const Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getSectionTitle('Exercises'),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => onAddExerciseClick(existingExerciseIds),
                      child: const Icon(
                        Icons.add,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

              if (snapshot.data!.workoutExercises == null ||
                  snapshot.data!.workoutExercises!.isEmpty) {
                return const Center(
                  child: Text('No exercises here...'),
                );
              }

              existingExerciseIds = snapshot.data!.workoutExercises!
                  .map((we) => we.exerciseId)
                  .toList();

              return Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Column(
                  children: getWorkoutExercisesWidget(
                    snapshot.data!.workoutExercises!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
