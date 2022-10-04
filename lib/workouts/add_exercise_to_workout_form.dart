import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:search_choices/search_choices.dart';

import '../db/classes/exercise.dart';

class AddExerciseToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final List<int>? existingExerciseIds;
  final void Function() reloadState;

  const AddExerciseToWorkoutForm({
    Key? key,
    required this.workoutId,
    required this.existingExerciseIds,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddExerciseToWorkoutForm> createState() =>
      _AddExerciseToWorkoutFormState();
}

class _AddExerciseToWorkoutFormState extends State<AddExerciseToWorkoutForm> {
  late Future<List<Exercise>> exercises;

  @override
  void initState() {
    super.initState();
    exercises = ExercisesHelper()
        .getAllExercisesExcludingIds(widget.existingExerciseIds!);
  }

  final formKey = GlobalKey<FormState>();
  List<Exercise> exercisesRef = [];
  List<int> selectedItems = [];
  List<DropdownMenuItem> items = [];

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        final List<int> exerciseIdsToAdd =
            selectedItems.map((si) => exercisesRef[si].id!).toList();

        await WorkoutsHelper.addExercisesToWorkout(
            widget.workoutId, exerciseIdsToAdd);
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add exercises to workout: $ex')),
        );
      }

      widget.reloadState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Exercise',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          FutureBuilder<List<Exercise>>(
            future: exercises,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }

              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No exercises here :('),
                );
              }

              exercisesRef = snapshot.data!;
              items = snapshot.data!
                  .map((e) => DropdownMenuItem(
                        value: e.name,
                        child: Text(e.name),
                      ))
                  .toList();

              return Form(
                key: formKey,
                child: Column(
                  children: [
                    SearchChoices.multiple(
                      items: items,
                      selectedItems: selectedItems,
                      hint: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Select exercises"),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            onPressed: onSubmit,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
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
