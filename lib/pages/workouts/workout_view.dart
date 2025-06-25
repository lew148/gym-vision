import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise_ordering.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_exercise_orderings_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/forms/add_category_to_workout_form.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/workouts/add_exercises_to_workout.dart';
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
  late Future<Workout?> workoutFuture;
  List<int> droppedWes = [];

  @override
  void initState() {
    super.initState();
    workoutFuture = WorkoutModel.getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeWorkoutExercises: true,
    );
  }

  void reloadState() => setState(() {
        workoutFuture = WorkoutModel.getWorkout(
          workoutId: widget.workoutId,
          includeCategories: true,
          includeWorkoutExercises: true,
        );
      });

  void onCategoriesChange(List<Category> newCategories) async {
    try {
      await WorkoutCategoryModel.setWorkoutCategories(widget.workoutId, newCategories);
      reloadState();
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Categories to workout.')));
    }
  }

  void onAddCategoryClick(List<Category> existingWorkoutCategoryIds) => CommonFunctions.showBottomSheet(
        context,
        CateogryPickerModal(
          selectedCategories: existingWorkoutCategoryIds,
          onChange: onCategoriesChange,
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
                  .map((wc) => CommonUI.getPropDisplay(
                        context,
                        wc.getCategoryDisplayName(),
                        onTap: () => goToMostRecentWorkout(wc),
                      ))
                  .toList(),
            ),
          ),
          CommonUI.getTextButton(
            ButtonDetails(
              icon: Icons.edit_rounded,
              onTap: () => onAddCategoryClick(existingCategories),
            ),
          ),
        ],
      );

  List<Widget> getWorkoutExercisesWidget(
      Workout workout, List<WorkoutExercise> workoutExercises, WorkoutExerciseOrdering? ordering) {
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
        .map((we) => Container(
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
                isInFuture: workout.isInFuture(),
              ),
            ))
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

  void showMoreMenu(Workout workout) => CommonFunctions.showOptionsMenu(
        context,
        [
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showEditDate(workout);
            },
            icon: Icons.calendar_today_rounded,
            text: 'Edit Date',
          ),
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showEditTime(workout);
            },
            icon: Icons.watch_rounded,
            text: 'Edit Time',
          ),
          ButtonDetails(
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
            icon: Icons.delete_rounded,
            text: 'Delete Workout',
            style: ButtonDetailsStyle(iconColor: Colors.red),
          ),
        ],
      );

  Widget getCategoriesWidget(Workout workout, List<Category> existingCategoryIds) =>
      workout.workoutCategories == null || workout.workoutCategories!.isEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonUI.getTextButton(
                  ButtonDetails(
                    onTap: () => onAddCategoryClick([]),
                    text: 'Add Categories',
                    icon: Icons.add_rounded,
                  ),
                ),
              ],
            )
          : getWorkoutCategoriesWidget(workout.workoutCategories!, existingCategoryIds);

  void onAddExerciseClick(int workoutId) => Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => AddExercisesToWorkout(workoutId: workoutId),
      ))
      .then((x) => reloadState());

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
    return FutureBuilder<Workout?>(
      future: workoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        if (!snapshot.hasData || snapshot.data == null) return const Center(child: Text("Failed to load workout."));

        final workout = snapshot.data!;
        final categories = workout.getCategories();
        final workoutExercises = workout.getWorkoutExercises();

        return DebugScaffold(
          customAppBarTitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.getDateOrDayStr(),
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                workout.getTimeStr(),
                style: TextStyle(color: Theme.of(context).colorScheme.shadow, fontSize: 15),
              ),
            ],
          ),
          customAppBarActions: [
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
              ),
              onPressed: () => showMoreMenu(workout),
            )
          ],
          body: Column(
            children: [
              getCategoriesWidget(workout, categories),
              CommonUI.getSectionTitleWithAction(
                context,
                'Exercises',
                ButtonDetails(
                  icon: Icons.add_rounded,
                  onTap: () => onAddExerciseClick(workout.id!),
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
                        children: getWorkoutExercisesWidget(workout, workoutExercises, workout.exerciseOrdering),
                      ),
                    ),
              const Padding(padding: EdgeInsetsGeometry.only(bottom: 10)),
            ],
          ),
        );
      },
    );
  }
}
