import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';

class WorkoutPicker extends StatefulWidget {
  final int? workoutId;
  final Workout? workout;
  final bool disabled;
  final Function setWorkout;

  const WorkoutPicker({
    Key? key,
    this.workoutId,
    this.workout,
    this.disabled = false,
    required this.setWorkout,
  }) : super(key: key);

  @override
  State<WorkoutPicker> createState() => _WorkoutPickerState();
}

class _WorkoutPickerState extends State<WorkoutPicker> {
  Future<Workout>? selectedWorkout;
  late Future<List<Workout>> allWorkouts;

  @override
  void initState() {
    super.initState();
    allWorkouts = WorkoutsHelper.getWorkouts();

    if (widget.workoutId != null && widget.workout == null) {
      selectedWorkout = WorkoutsHelper.getWorkout(workoutId: widget.workoutId!);
    }
  }

  void showWorkoutPicker(
    List<Workout> workoutsList,
    Workout? selectedWorkout,
  ) =>
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Select Workout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(thickness: 0.25),
                    SizedBox(
                      height: 500,
                      child: SingleChildScrollView(
                        child: Column(
                          children: workoutsList
                              .map(
                                (w) => Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.setWorkout(w);
                                    },
                                    child: Card(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          border: Border.all(
                                            width: 2,
                                            color: selectedWorkout != null && w.id == selectedWorkout.id
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.transparent,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          children: [
                                            Text(
                                              w.getDateAndTimeString(),
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  List<Widget> getPickerIcons() => [
        const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(Icons.arrow_drop_down_rounded),
        ),
        IconButton(
          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
          onPressed: () => widget.setWorkout(null),
          icon: const Icon(Icons.clear_rounded),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Workout>>(
      future: allWorkouts,
      builder: ((context, allWorkoutsSnapshot) {
        if (!allWorkoutsSnapshot.hasData || allWorkoutsSnapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final mostRecentWorkout = allWorkoutsSnapshot.data!.firstWhere((w) => w.date.isBefore(DateTime.now()));

        return FutureBuilder<Workout>(
          future: selectedWorkout,
          builder: ((context, snapshot) {
            final workout = widget.workout ?? snapshot.data;

            return widget.disabled
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showWorkoutPicker(
                            allWorkoutsSnapshot.data!,
                            workout,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            height: 60,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Text(
                                          workout == null ? '' : 'Workout',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.shadow,
                                          ),
                                        ),
                                      ]),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                      ),
                                      Row(children: [
                                        Text(
                                          workout == null ? 'Select Workout' : workout.getDateAndTimeString(),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                            color: workout == null ? Theme.of(context).colorScheme.shadow : null,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                ...getPickerIcons(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                        child: TextButton(
                          onPressed: () => widget.setWorkout(mostRecentWorkout),
                          child: const Text('Most Recent'),
                        ),
                      ),
                    ],
                  );
          }),
        );
      }),
    );
  }
}
