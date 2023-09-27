import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/workouts/workout_exercise_widget.dart';

import '../db/classes/workout.dart';
import '../db/classes/workout_category.dart';
import '../db/helpers/workouts_helper.dart';
import '../shared/forms/add_set_to_workout_form.dart';
import '../shared/ui_helper.dart';
import '../shared/forms/add_category_to_workout_form.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final Function reloadParent;

  const WorkoutView({
    super.key,
    required this.workoutId,
    required this.reloadParent,
  });

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
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
        Navigator.pop(context);

        try {
          await WorkoutsHelper.deleteWorkout(workoutId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete Workout: ${ex.toString()}'),
            ),
          );
        }

        widget.reloadParent();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete Workout?"),
      content: const Text("Are you sure you would like to delete this Workout?"),
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

  void onAddCategoryClick(List<int> existingWorkoutCategoryIds) => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AddCategoryToWorkoutForm(
                workoutId: widget.workoutId,
                selectedWorkoutCategoryIds: existingWorkoutCategoryIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      );

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<int> existingCategoryIds) =>
      Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: workoutCategories.map((wc) => getPropDisplay(context, wc.getDisplayName())).toList(),
              ),
            ),
            getPrimaryButton(
              actionButton: ActionButton(
                icon: Icons.edit_rounded,
                onTap: () => onAddCategoryClick(existingCategoryIds),
              ),
            ),
          ],
        ),
        const Divider(),
      ]);

  List<Widget> getWorkoutExercisesWidget(List<WorkoutSet>? workoutSets) {
    if (workoutSets == null || workoutSets.isEmpty) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text('No Exercises added yet...'),
          ),
        ),
      ];
    }

    final Map<int, List<WorkoutSet>> groupedWorkoutExercises = groupBy<WorkoutSet, int>(
      workoutSets,
      (x) => x.exerciseId,
    );

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: WorkoutExerciseWidget(
            workoutSets: value,
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
      // do nothing
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
      // do nothing
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
                    Icon(Icons.calendar_today_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Date',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                    Icon(Icons.watch_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Time',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                  showDeleteWorkoutConfirm(workout.id!);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    const Text(
                      'Delete Workout',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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

  Widget getCategoriesWidget(Workout workout, List<int> existingCategoryIds) =>
      workout.workoutCategories == null || workout.workoutCategories!.isEmpty
          ? Row(children: [
              Expanded(
                child: getPrimaryButton(
                  actionButton: ActionButton(
                    onTap: () => onAddCategoryClick([]),
                    text: 'Add Categories',
                    icon: Icons.add_rounded,
                  ),
                ),
              ),
            ])
          : getWorkoutCategoriesWidget(workout.workoutCategories!, existingCategoryIds);

  @override
  Widget build(BuildContext context) {
    Future<Workout?> workout = WorkoutsHelper.getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeSets: true,
    );

    List<int> existingCategoryShellIds = [];
    List<int> existingExerciseIds = [];

    return FutureBuilder<Workout?>(
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

        if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty) {
          existingCategoryShellIds = workout.workoutCategories!.map((wc) => wc.categoryShellId).toList();
        } else {
          existingCategoryShellIds = [];
        }

        if (workout.workoutSets != null && workout.workoutSets!.isNotEmpty) {
          existingExerciseIds = workout.workoutSets!.map((ws) => ws.exerciseId).toSet().toList();
        } else {
          existingExerciseIds = [];
        }

        void onAddExerciseClick() => showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: AddSetToWorkoutForm(
                      workoutId: workout.id,
                      excludeExerciseIds: existingExerciseIds,
                      categoryShellIds: existingCategoryShellIds,
                      reloadState: reloadState,
                    ),
                  ),
                ],
              ),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
            );

        return Scaffold(
          appBar: AppBar(
            title: Text(workout.getDateAndTimeString()),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                ),
                onPressed: () => showMoreMenu(workout, reloadState),
              )
            ],
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  getCategoriesWidget(workout, existingCategoryShellIds),
                  const Padding(padding: EdgeInsets.all(5)),
                  getSectionTitleWithAction(
                    context,
                    'Exercises',
                    ActionButton(
                      icon: Icons.add,
                      onTap: onAddExerciseClick,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: getWorkoutExercisesWidget(workout.workoutSets),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
