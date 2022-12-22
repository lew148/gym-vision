import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/exercises/category_view.dart';
import 'package:gymvision/workouts/workout_exercise_widget.dart';

import '../db/classes/workout.dart';
import '../db/classes/workout_category.dart';
import '../db/helpers/workouts_helper.dart';
import '../shared/forms/add_exercise_to_workout_form.dart';
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

  void onAddCategoryClick(List<int> existingCategoryIds) => showModalBottomSheet(
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
                selectedCategoryIds: existingCategoryIds,
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

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories) {
    workoutCategories.sort((a, b) => a.category!.name.compareTo(b.category!.name));

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: workoutCategories
          .map(
            (wc) => Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
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
                  padding: const EdgeInsets.all(10),
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
                      const Icon(Icons.chevron_right_rounded, size: 18)
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void onAddExerciseClick(int workoutId, List<int> existingExerciseIds, List<int>? categoryIds) => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AddExerciseToWorkoutForm(
                workoutId: workoutId,
                excludeExerciseIds: existingExerciseIds,
                categoryIds: categoryIds,
                disableWorkoutPicker: true,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  List<Widget> getWorkoutExercisesWidget(List<WorkoutExercise>? workoutExercises) {
    if (workoutExercises == null || workoutExercises.isEmpty) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text('No Exercises added yet...'),
          ),
        ),
      ];
    }

    final Map<int, List<WorkoutExercise>> groupedWorkoutExercises = groupBy<WorkoutExercise, int>(
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
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  List<Widget> getCategoriesParts(Workout workout, List<int> existingCategoryIds) =>
      workout.workoutCategories == null || workout.workoutCategories!.isEmpty
          ? [
              Row(children: [
                Expanded(
                  child: getPrimaryButton(
                    actionButton: ActionButton(
                      onTap: () => onAddCategoryClick([]),
                      text: 'Add Categories',
                      icon: Icons.add_rounded,
                    ),
                  ),
                ),
              ]),
              const Padding(padding: EdgeInsets.all(5)),
            ]
          : [
              getSectionTitleWithAction(
                context,
                'Categories',
                ActionButton(
                  icon: Icons.edit_rounded,
                  onTap: () => onAddCategoryClick(existingCategoryIds),
                ),
              ),
              const Divider(),
              getWorkoutCategoriesWidget(workout.workoutCategories!),
            ];

  @override
  Widget build(BuildContext context) {
    Future<Workout> workout = WorkoutsHelper.getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeExercises: true,
    );

    List<int> existingCategoryIds = [];
    List<int> existingExerciseIds = [];

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

        if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty) {
          existingCategoryIds = workout.workoutCategories!.map((wc) => wc.categoryId).toList();
        } else {
          existingCategoryIds = [];
        }

        if (workout.workoutExercises != null && workout.workoutExercises!.isNotEmpty) {
          existingExerciseIds = workout.workoutExercises!.map((we) => we.exerciseId).toList();
        } else {
          existingExerciseIds = [];
        }

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
            child: Column(
              children: [
                ...getCategoriesParts(workout, existingExerciseIds),
                const Padding(padding: EdgeInsets.all(5)),
                getSectionTitleWithAction(
                  context,
                  'Exercises',
                  ActionButton(
                    icon: Icons.add,
                    onTap: () => onAddExerciseClick(workout.id!, existingExerciseIds,
                        workout.workoutCategories?.map((wc) => wc.categoryId).toList()),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: getWorkoutExercisesWidget(
                        workout.workoutExercises,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
