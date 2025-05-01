import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_category.dart';
import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/classes/db/workout_exercise_ordering.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/forms/add_category_to_workout_form.dart';
import 'package:gymvision/pages/forms/add_set_to_workout_form.dart';
import 'package:gymvision/pages/ui_helper.dart';
import 'package:gymvision/pages/workouts/workout_exercise_widget.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:reorderables/reorderables.dart';

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
  List<int> droppedWes = [];

  reloadState({int? wexId}) => setState(() {
        if (wexId != null) {
          droppedWes.contains(wexId) ? droppedWes.remove(wexId) : droppedWes.add(wexId);
        }
      });

  void onAddCategoryClick(List<Category> existingWorkoutCategoryIds) => showModalBottomSheet(
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
                existingCategories: existingWorkoutCategoryIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  goToMostRecentWorkout(WorkoutCategory wc) async {
    var id = await WorkoutModel.getMostRecentWorkoutIdForCategory(wc);
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

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) =>
      Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: workoutCategories //todo: sort
                    .map((wc) => UiHelper.getTappablePropDisplay(
                          context,
                          wc.getCategoryDisplayName(),
                          () => goToMostRecentWorkout(wc),
                        ))
                    .toList(),
              ),
            ),
            UiHelper.getPrimaryButton(
              ActionButton(
                icon: Icons.edit_rounded,
                onTap: () => onAddCategoryClick(existingCategories),
              ),
            ),
          ],
        ),
        const Divider(thickness: 0.25),
      ]);

  List<Widget> getWorkoutExercisesWidget(List<WorkoutExercise> workoutExercises, WorkoutExerciseOrdering? ordering) {
    // if (ordering != null) {
    //   final Map<int, List<WorkoutSet>> remainder = groupedWorkoutExercises;
    //   final Map<int, List<WorkoutSet>> newOrder = {};
    //   for (var i in ordering.getPositions()) {
    //     final group = groupedWorkoutExercises[i];
    //     if (group == null) continue;
    //     newOrder.addAll({i: group});
    //     remainder.remove(i);
    //   }

    //   newOrder.addAll(remainder);
    //   groupedWorkoutExercises = newOrder;
    // }

    return workoutExercises
        .map(
          (we) => Container(
            key: Key(we.id.toString()),
            child: WorkoutExerciseWidget(
              workoutExercise: we,
              reloadState: reloadState,
              dropped: droppedWes.contains(we.id),
            ),
          ),
        )
        .toList();
  }

  void showEditDate(Workout workout, void Function() reloadState) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: workout.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    try {
      await WorkoutModel.updateDate(workout.id!, newDate!);
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
      await WorkoutModel.updateTime(workout.id!, newTime!);
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
                    () => WorkoutModel.deleteWorkout(workout.id!),
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

  Widget getCategoriesWidget(Workout workout, List<Category> existingCategoryIds) =>
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
    Future<Workout?> workout = WorkoutModel.getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeWorkoutExercises: true,
    );

    List<Category> setCategories = [];

    return FutureBuilder<Workout?>(
      future: workout,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // loading
        }

        final workout = snapshot.data!;
        final workoutExercises = workout.getWorkoutExercises();

        if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty) {
          setCategories = workout.workoutCategories!.map((wc) => wc.category).toList();
        } else {
          setCategories = [];
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
                      workoutId: workout.id!,
                      setCategories: setCategories,
                      excludedExercises: workoutExercises.map((we) => we.exerciseIdentifier).toList(),
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
            await WorkoutExerciseOrderingsModel.reorderPositioning(widget.workoutId, oldIndex, newIndex);
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
                  getCategoriesWidget(workout, setCategories),
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
                  workoutExercises.isEmpty
                      ? const Center(
                          child: Padding(padding: EdgeInsets.all(15), child: Text('No Exercises added yet...')),
                        )
                      : Expanded(
                          child: ReorderableColumn(
                            onReorder: onWorkoutExerciseReorder,
                            children: getWorkoutExercisesWidget(workoutExercises, workout.exerciseOrdering),
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
