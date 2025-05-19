import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/classes/db/workout_category.dart';
import 'package:gymvision/classes/db/workout_exercise.dart';
import 'package:gymvision/classes/db/workout_exercise_ordering.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/forms/add_category_to_workout_form.dart';
import 'package:gymvision/pages/forms/add_set_to_workout_form.dart';
import 'package:gymvision/pages/common/common_ui.dart';
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

  void reloadState() => setState(() {
        droppedWes = droppedWes;
      });

  void onAddCategoryClick(List<Category> existingWorkoutCategoryIds) => CommonFunctions.showBottomSheet(
        context,
        AddCategoryToWorkoutForm(
          workoutId: widget.workoutId,
          existingCategories: existingWorkoutCategoryIds,
          reloadState: reloadState,
        ),
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

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.start,
              children: workoutCategories //todo: sort
                  .map((wc) => CommonUI.getTappablePropDisplay(
                        context,
                        wc.getCategoryDisplayName(),
                        () => goToMostRecentWorkout(wc),
                      ))
                  .toList(),
            ),
          ),
          CommonUI.getPrimaryButton(
            ButtonDetails(
              icon: Icons.edit_rounded,
              onTap: () => onAddCategoryClick(existingCategories),
            ),
          ),
        ],
      );

  List<Widget> getWorkoutExercisesWidget(List<WorkoutExercise> workoutExercises, WorkoutExerciseOrdering? ordering) {
    if (ordering != null) {
      final List<WorkoutExercise> remainder = workoutExercises;
      final List<WorkoutExercise> newOrder = [];
      for (var weId in ordering.getPositions()) {
        var we = remainder.firstWhereOrNull((we) => we.id == weId);
        if (we == null) continue;
        newOrder.add(we);
        remainder.removeWhere((we) => we.id == weId);
      }

      newOrder.addAll(remainder);
      workoutExercises = newOrder;
    }

    return workoutExercises
        .map(
          (we) => Container(
            key: Key(we.id.toString()),
            child: WorkoutExerciseWidget(
              workoutExercise: we,
              reloadParent: reloadState,
              toggleDroppedParent: (int? wexId) {
                if (wexId != null) {
                  droppedWes.contains(wexId) ? droppedWes.remove(wexId) : droppedWes.add(wexId);
                }
              },
              dropped: droppedWes.contains(we.id),
            ),
          ),
        )
        .toList();
  }

  void showEditDate(Workout workout) async {
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

  void showEditTime(Workout workout) async {
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

  void showMoreMenu(Workout workout) {
    CommonFunctions.showBottomSheet(
      context,
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                showEditDate(workout);
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
          CommonUI.getDefaultDivider(),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                showEditTime(workout);
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
          CommonUI.getDefaultDivider(),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                CommonFunctions.showDeleteConfirm(
                  context,
                  "workout",
                  () => WorkoutModel.deleteWorkout(workout.id!),
                  widget.reloadParent,
                  popCaller: true,
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
    );
  }

  Widget getCategoriesWidget(Workout workout, List<Category> existingCategoryIds) =>
      workout.workoutCategories == null || workout.workoutCategories!.isEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonUI.getPrimaryButton(
                  ButtonDetails(
                    onTap: () => onAddCategoryClick([]),
                    text: 'Add Categories',
                    icon: Icons.add_rounded,
                  ),
                ),
              ],
            )
          : getWorkoutCategoriesWidget(workout.workoutCategories!, existingCategoryIds);

  void onAddExerciseClick(Workout workout, List<Category> setCategories, List<WorkoutExercise> workoutExercises) =>
      CommonFunctions.showBottomSheet(
        context,
        AddSetToWorkoutForm(
          workoutId: workout.id!,
          setCategories: setCategories,
          excludedExercises: workoutExercises.map((we) => we.exerciseIdentifier).toList(),
          reloadState: reloadState,
        ),
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

        return DebugScaffold(
          customAppBar: AppBar(
            title: Row(
              children: [
                Text(
                  workout.getDateStr(),
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' @ ${workout.getTimeStr()}',
                  style: TextStyle(color: Theme.of(context).colorScheme.shadow, fontSize: 15),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                ),
                onPressed: () => showMoreMenu(workout),
              ),
            ],
          ),
          body: Column(
            children: [
              getCategoriesWidget(workout, setCategories),
              CommonUI.getSectionTitleWithAction(
                context,
                'Exercises',
                ButtonDetails(
                  icon: Icons.add,
                  onTap: () => onAddExerciseClick(workout, setCategories, workoutExercises),
                ),
              ),
              CommonUI.getDefaultDivider(),
              workoutExercises.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Tap + to record an Exercise!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ))
                  : Expanded(
                      child: ReorderableColumn(
                        onReorder: onWorkoutExerciseReorder,
                        children: getWorkoutExercisesWidget(workoutExercises, workout.exerciseOrdering),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
