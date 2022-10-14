import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:search_choices/search_choices.dart';

import '../globals.dart';

class AddExerciseToWorkoutsForm extends StatefulWidget {
  final int exerciseId;

  const AddExerciseToWorkoutsForm({
    Key? key,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<AddExerciseToWorkoutsForm> createState() =>
      _AddExerciseToWorkoutsFormState();
}

class _AddExerciseToWorkoutsFormState extends State<AddExerciseToWorkoutsForm> {
  late Future<List<Workout>> workouts;

  @override
  void initState() {
    super.initState();
    workouts = WorkoutsHelper().getWorkouts();
  }

  final formKey = GlobalKey<FormState>();
  final setsController = TextEditingController(text: '3');
  List<Workout> workoutsRef = [];
  List<int> selectedItems = [];
  List<DropdownMenuItem> items = [];

  void onSubmit() async {
    final List<int> workoutIdsToAddTo =
        selectedItems.map((si) => workoutsRef[si].id!).toList();
    addExerciseToWorkouts(workoutIdsToAddTo);
  }

  void onRecentWorkoutButtonPress(int recentWorkoutId) async =>
      addExerciseToWorkouts([recentWorkoutId]);

  void addExerciseToWorkouts(List<int> workoutIds) async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        await WorkoutsHelper.addExerciseToWorkouts(
          widget.exerciseId,
          workoutIds,
          int.parse(getNumberOrDefault(setsController.text)),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added exercise to workouts!')),
          );
        }
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add exercise to workouts: $ex')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Exercise To Workouts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          FutureBuilder<List<Workout>>(
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

              final mostRecentWorkout = snapshot.data![0];
              workoutsRef = snapshot.data!;
              items = snapshot.data!
                  .map((e) => DropdownMenuItem(
                        value: e.id,
                        child:
                            Text('${e.getDateString()} @ ${e.getTimeString()}'),
                      ))
                  .toList();

              return Form(
                key: formKey,
                child: Column(
                  children: [
                    if (snapshot.data!.any((w) => w.isToday()))
                      SearchChoices.multiple(
                        items: items,
                        autofocus: false,
                        selectedItems: selectedItems,
                        hint: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text("Select Workouts"),
                        ),
                        searchHint: '',
                        onChanged: (value) {
                          setState(() {
                            selectedItems = value;
                          });
                        },
                        closeButton: (selectedItems) {
                          return (selectedItems.isNotEmpty
                              ? "Select ${selectedItems.length == 1 ? '"${items[selectedItems.first].value}"' : '(${selectedItems.length})'}"
                              : "Cancel");
                        },
                        doneButton: '',
                        isExpanded: true,
                      ),
                    TextFormField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => onRecentWorkoutButtonPress(
                                mostRecentWorkout.id!),
                            child: const Text('Add to Most Recent'),
                          ),
                          ElevatedButton(
                            onPressed: onSubmit,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
