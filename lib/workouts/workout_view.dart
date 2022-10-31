import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/exercises/category_view.dart';
import 'package:gymvision/workouts/workout_exercise_widget.dart';

import '../db/classes/workout.dart';
import '../db/classes/workout_category.dart';
import '../db/helpers/workouts_helper.dart';
import '../shared/ui_helper.dart';
import '../shared/forms/add_category_to_workout_form.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  const WorkoutView({super.key, required this.workoutId});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  reloadState() => setState(() {});

  // void onAddExerciseClick(List<int> existingExerciseIds) =>
  // showModalBottomSheet(
  //   context: context,
  //   builder: (BuildContext context) => Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom),
  //         child: AddExerciseToWorkoutForm(
  //           workoutId: widget.workoutId,
  //           existingExerciseIds: existingExerciseIds,
  //           reloadState: reloadState,
  //         ),
  //       ),
  //     ],
  //   ),
  //   isScrollControlled: true,
  //   shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
  // );

  void onAddCategoryClick(List<int> existingCategoryIds) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddCategoryToWorkoutForm(
                workoutId: widget.workoutId,
                existingCategoryIds: existingCategoryIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  void showRemoveCategoryFromWorkoutConfirm(int workoutCategoryId) {
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
          await WorkoutsHelper.removeCategoryFromWorkout(workoutCategoryId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to remove Category from workout: ${ex.toString()}',
              ),
            ),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Category from Workout?"),
      content: const Text(
        "Are you sure you would like to remove this Category from this workout?",
      ),
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

  getWorkoutCategoriesWidget(List<WorkoutCategory>? workoutCategories) {
    if (workoutCategories == null || workoutCategories.isEmpty) {
      return const Center(
        child: Text('No Category set yet.'),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: workoutCategories
          .map(
            (wc) => Padding(
              padding: const EdgeInsets.all(5),
              child: InkWell(
                onLongPress: () => showRemoveCategoryFromWorkoutConfirm(wc.id!),
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => CategoryView(
                          categoryId: wc.categoryId,
                          categoryName: wc.category!.name,
                        ),
                      ),
                    )
                    .then((value) => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.75,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    children: [
                      Text(
                        wc.category!.getDisplayName(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18)
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  List<Widget> getWorkoutExercisesWidget(
      List<WorkoutExercise>? workoutExercises) {
    if (workoutExercises == null || workoutExercises.isEmpty) {
      return const [
        Center(
          child: Text('No Exercises added yet.'),
        ),
      ];
    }

    final Map<int, List<WorkoutExercise>> groupedWorkoutExercises =
        groupBy<WorkoutExercise, int>(
      workoutExercises,
      (x) => x.exerciseId,
    );

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: WorkoutExerciseWidget(
            workoutExercises: value,
            reloadState: reloadState,
          ),
        ),
      );
    });

    return weWidgets;
  }

  void showEditDate(Workout workout, void Function() reloadState) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: workout.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    try {
      await WorkoutsHelper.updateDate(workout.id!, newDate!);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update date: $ex')),
      );
    }

    reloadState();
  }

  void showEditTime(Workout workout, void Function() reloadState) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(workout.date),
    );

    try {
      await WorkoutsHelper.updateTime(workout.id!, newTime!);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update time: $ex')),
      );
    }

    reloadState();
  }

  void showMoreMenu(Workout workout, void Function() reloadState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showEditDate(workout, reloadState);
                },
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Date',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showEditTime(workout, reloadState);
                },
                child: Row(
                  children: const [
                    Icon(Icons.watch),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Time',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<Workout> workout = WorkoutsHelper.getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeExercises: true,
    );

    List<int> existingCategoryIds = [];
    List<int> existingExerciseIds = [];

    reloadState() => setState(() {});

    return FutureBuilder<Workout>(
      future: workout,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Scaffold(
              body: Text('Loading...'),
            ),
          );
        }

        final workout = snapshot.data!;

        if (workout.workoutCategories != null &&
            workout.workoutCategories!.isNotEmpty) {
          existingCategoryIds =
              workout.workoutCategories!.map((we) => we.categoryId).toList();
        } else {
          existingCategoryIds = [];
        }

        if (workout.workoutExercises != null &&
            workout.workoutExercises!.isNotEmpty) {
          existingExerciseIds =
              workout.workoutExercises!.map((we) => we.exerciseId).toList();
        } else {
          existingExerciseIds = [];
        }

        return Scaffold(
          appBar: AppBar(
            title:
                Text('${workout.getDateString()} @ ${workout.getTimeString()}'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                ),
                onPressed: () => showMoreMenu(workout, reloadState),
              )
            ],
          ),
          body: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSectionTitle(context, 'Categories'),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              onAddCategoryClick(existingCategoryIds),
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
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                padding: const EdgeInsets.all(10),
                child: getWorkoutCategoriesWidget(
                  workout.workoutCategories,
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSectionTitle(context, 'Exercises'),
                  // Container(
                  //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  //   child: Row(
                  //     children: [
                  //       OutlinedButton(
                  //         onPressed: () =>
                  //             onAddExerciseClick(existingExerciseIds),
                  //         child: const Icon(
                  //           Icons.add,
                  //           size: 25,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: getWorkoutExercisesWidget(
                        workout.workoutExercises,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
