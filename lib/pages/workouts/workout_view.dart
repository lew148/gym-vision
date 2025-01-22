import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/db/classes/workout_exercise_ordering.dart';
import 'package:gymvision/db/classes/workout_set.dart';
import 'package:gymvision/db/helpers/workout_exercise_orderings_helper.dart';
import 'package:gymvision/helpers/category_shell_helper.dart';
import 'package:gymvision/pages/workouts/workout_exercise_widget.dart';
import 'package:reorderables/reorderables.dart';

import '../../db/classes/workout.dart';
import '../../db/classes/workout_category.dart';
import '../../db/helpers/workouts_helper.dart';
import '../../forms/add_set_to_workout_form.dart';
import '../../helpers/ui_helper.dart';
import '../../forms/add_category_to_workout_form.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final Function? reloadParent;

  const WorkoutView({
    super.key,
    required this.workoutId,
    this.reloadParent,
  });

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  late Map<int, List<WorkoutSet>> groupedWorkoutExercises;
  List<int> droppedWes = [];

  reloadState({int? eId}) => setState(() {
        if (eId != null) {
          droppedWes.contains(eId) ? droppedWes.remove(eId) : droppedWes.add(eId);
        }
      });

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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  goToMostRecentWorkout(WorkoutCategory wc) async {
    var id = await WorkoutsHelper.getMostRecentWorkoutForCategory(wc);
    if (id == null) return;
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutView(
          workoutId: id,
          reloadParent: reloadState,
        ),
      ),
    );
  }

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<int> existingCategoryIds) =>
      Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: CategoryShellHelper.sortCategories(workoutCategories)
                    .map((wc) => UiHelper.getTappablePropDisplay(
                          context,
                          wc.getDisplayName(),
                          () => goToMostRecentWorkout(wc),
                        ))
                    .toList(),
              ),
            ),
            UiHelper.getPrimaryButton(
              ActionButton(
                icon: Icons.edit_rounded,
                onTap: () => onAddCategoryClick(existingCategoryIds),
              ),
            ),
          ],
        ),
        const Divider(thickness: 0.25),
      ]);

  List<Widget> getWorkoutExercisesWidget(List<WorkoutSet> workoutSets, WorkoutExerciseOrdering? ordering) {
    groupedWorkoutExercises = groupBy<WorkoutSet, int>(
      workoutSets,
      (x) => x.exerciseId,
    );

    if (ordering != null) {
      final Map<int, List<WorkoutSet>> remainder = groupedWorkoutExercises;
      final Map<int, List<WorkoutSet>> newOrder = {};
      for (var i in ordering.getPositions()) {
        final group = groupedWorkoutExercises[i];
        if (group == null) continue;
        newOrder.addAll({i: group});
        remainder.remove(i);
      }

      newOrder.addAll(remainder);
      groupedWorkoutExercises = newOrder;
    }

    List<Widget> weWidgets = [];
    groupedWorkoutExercises.forEach((key, value) {
      weWidgets.add(
        Container(
          key: Key('$key'),
          child: WorkoutExerciseWidget(
            workoutSets: value,
            reloadState: reloadState,
            dropped: droppedWes.contains(key),
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
                child: const Row(
                  children: [
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
            const Divider(thickness: 0.25),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showEditTime(workout, reloadState);
                },
                child: const Row(
                  children: [
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
            const Divider(thickness: 0.25),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  UiHelper.showDeleteConfirm(
                    context,
                    () => WorkoutsHelper.deleteWorkout(workout.id!),
                    reloadState,
                    "workout",
                  );
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
                child: UiHelper.getPrimaryButton(
                  ActionButton(
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

    return FutureBuilder<Workout?>(
      future: workout,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // loading
        }

        final workout = snapshot.data!;

        if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty) {
          existingCategoryShellIds = workout.workoutCategories!.map((wc) => wc.categoryShellId).toList();
        } else {
          existingCategoryShellIds = [];
        }

        // if (workout.workoutSets != null && workout.workoutSets!.isNotEmpty) {
        //   existingExerciseIds = distinctIntList(workout.workoutSets!.map((ws) => ws.exerciseId));
        // } else {
        //   existingExerciseIds = [];
        // }

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
                      categoryShellIds: existingCategoryShellIds,
                      reloadState: reloadState,
                    ),
                  ),
                ],
              ),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
            );

        void onWorkoutExerciseReorder(int oldIndex, int newIndex) async {
          try {
            HapticFeedback.mediumImpact();
            await WorkoutExerciseOrderingsHelper.reorderPositioning(widget.workoutId, oldIndex, newIndex);
          } catch (e) {
            // do nothing
          }

          reloadState();
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.getDateStr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    workout.getTimeStr(),
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow, fontSize: 15),
                  ),
                ],
              ),
            ]),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                ),
                onPressed: () => showMoreMenu(workout, reloadState),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 20),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  getCategoriesWidget(workout, existingCategoryShellIds),
                  const Padding(padding: EdgeInsets.all(5)),
                  UiHelper.getSectionTitleWithAction(
                    context,
                    'Exercises',
                    ActionButton(
                      icon: Icons.add,
                      onTap: onAddExerciseClick,
                    ),
                  ),
                  const Divider(thickness: 0.25),
                  workout.workoutSets == null || workout.workoutSets!.isEmpty
                      ? const Center(
                          child: Padding(padding: EdgeInsets.all(15), child: Text('No Exercises added yet...')))
                      : Expanded(
                          child: ReorderableColumn(
                            onReorder: onWorkoutExerciseReorder,
                            children: getWorkoutExercisesWidget(workout.workoutSets!, workout.ordering),
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
