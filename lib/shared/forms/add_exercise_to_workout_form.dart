import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:search_choices/search_choices.dart';

import '../../db/classes/exercise.dart';
import '../../globals.dart';

class AddExerciseToWorkoutForm extends StatefulWidget {
  final Exercise exercise;
  final int? workoutId;

  const AddExerciseToWorkoutForm({
    Key? key,
    required this.exercise,
    this.workoutId,
  }) : super(key: key);

  @override
  State<AddExerciseToWorkoutForm> createState() =>
      _AddExerciseToWorkoutFormState();
}

class _AddExerciseToWorkoutFormState extends State<AddExerciseToWorkoutForm> {
  final formKey = GlobalKey<FormState>();
  List<Workout> workoutsRef = [];
  List<int> selectedItems = [];
  List<DropdownMenuItem> items = [];

  final setsController = TextEditingController(text: '3');
  late TextEditingController weightController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();
    weightController =
        TextEditingController(text: widget.exercise.getWeightAsString());
    repsController =
        TextEditingController(text: widget.exercise.reps.toString());
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Workout>> workouts = WorkoutsHelper.getWorkouts();

    void onSubmit() async {
      final List<int> workoutIdsToAddTo = widget.workoutId == null
          ? selectedItems.map((si) => workoutsRef[si].id!).toList()
          : [widget.workoutId!];

      if (workoutIdsToAddTo.isEmpty) {
        return;
      }

      if (formKey.currentState!.validate()) {
        Navigator.pop(context);

        try {
          await WorkoutsHelper.addExerciseToWorkouts(
            exerciseId: widget.exercise.id!,
            workoutIds: workoutIdsToAddTo,
            weight:
                double.parse(getNumberStringOrDefault(weightController.text)),
            reps: int.parse(getNumberStringOrDefault(repsController.text)),
            sets: int.parse(getNumberStringOrDefault(setsController.text)),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added exercise to workout${workoutIdsToAddTo.length == 1 ? '' : 's'}!',
                ),
              ),
            );
          }
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add exercise to workout${workoutIdsToAddTo.length == 1 ? '' : 's'}: $ex',
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Exercise To Workouts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          getSectionTitle(context, widget.exercise.name),
          const Divider(),
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
                  child: Text('No Workouts to Add Exercises to :('),
                );
              }

              final mostRecentWorkoutIndex = snapshot.data!
                  .indexWhere((w) => w.date.isBefore(DateTime.now()));

              workoutsRef = snapshot.data!;
              items = snapshot.data!
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child:
                          Text('${e.getDateString()} @ ${e.getTimeString()}'),
                    ),
                  )
                  .toList();

              return Form(
                key: formKey,
                child: Column(
                  children: [
                    if (widget.workoutId == null)
                      Row(
                        children: [
                          Expanded(
                            child: SearchChoices.multiple(
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
                                    ? "Select${selectedItems.length == 1 ? '' : ' (${selectedItems.length})'}"
                                    : "Cancel");
                              },
                              doneButton: '',
                              isExpanded: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                selectedItems = [mostRecentWorkoutIndex];
                              }),
                              child: const Text('Most Recent'),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              prefix: widget.exercise.isSingle
                                  ? const Text('')
                                  : const Text('2 x '),
                              suffix: const Text('kg'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              weightController.text =
                                  widget.exercise.getWeightAsString();
                            }),
                            child: const Text('Default'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              weightController.text = widget.exercise.max == 0
                                  ? widget.exercise.getWeightAsString()
                                  : widget.exercise.getMaxAsString();
                            }),
                            child: const Text('Max'),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
