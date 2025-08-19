import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:gymvision/pages/workouts/rest_timer.dart';
import 'package:gymvision/pages/forms/category_picker.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/add_exercises_to_workout.dart';
import 'package:gymvision/pages/workouts/time_elapsed_widget.dart';
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
  late bool workoutIsFinished;

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
      showSnackBar(context, 'Failed to add Categories to workout.');
    }
  }

  void onAddCategoryClick(List<Category> existingWorkoutCategoryIds) => showCustomBottomSheet(
        context,
        CateogryPicker(
          selectedCategories: existingWorkoutCategoryIds,
          onChange: onCategoriesChange,
        ),
      );

  goToMostRecentWorkout(WorkoutCategory wc) async {
    var id = await WorkoutModel.getMostRecentWorkoutIdForCategory(wc);
    if (!mounted) return;

    if (id == null) {
      showSnackBar(context, 'No previous workouts for this category.');
      return;
    }

    openWorkoutView(context, id, reloadState: reloadState);
  }

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.start,
              children: workoutCategories //todo: sort
                  .map((wc) => CommonUI.getSmallPropDisplay(
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
    Workout workout,
    List<WorkoutExercise> workoutExercises,
    WorkoutExerciseOrdering? ordering,
  ) {
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

  void showEditDate(Workout workout) => showDateTimePicker(
        context,
        initialDateTime: workout.date,
        CupertinoDatePickerMode.date,
        (DateTime dt) async {
          try {
            await WorkoutModel.updateDate(workout.id!, dt);
            reloadState();
          } catch (ex) {
            // do nothing
          }
        },
      );

  void showEditTime(Workout workout) => showDateTimePicker(
        context,
        initialDateTime: workout.date,
        CupertinoDatePickerMode.time,
        (DateTime dt) async {
          try {
            await WorkoutModel.updateTime(workout.id!, dt);
            reloadState();
          } catch (ex) {
            // do nothing
          }
        },
      );

  void showMoreMenu(Workout workout) => showOptionsMenu(
        context,
        [
          ButtonDetails(
            onTap: () async {
              Navigator.pop(context);

              try {
                final exportString = await WorkoutModel.getWorkoutExportString(workout.id!);
                if (exportString == null) throw Exception();
                await Clipboard.setData(ClipboardData(text: exportString));
                if (mounted) showSnackBar(context, 'Workout copied to clipboard!');
              } catch (ex) {
                if (mounted) showSnackBar(context, 'Failed to export workout.');
              }
            },
            icon: Icons.share_rounded,
            text: 'Export Workout',
          ),
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
            icon: Icons.access_time_rounded,
            text: 'Edit Time',
          ),
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showDeleteConfirm(
                context,
                "workout",
                () => WorkoutModel.deleteWorkout(workout.id!),
                widget.reloadParent,
                popCaller: true,
              );
            },
            icon: Icons.delete_rounded,
            text: 'Delete Workout',
            style: ButtonDetailsStyle.redIcon,
          ),
        ],
      );

  Widget getCategoriesWidget(Workout workout, List<Category> existingCategoryIds) =>
      workout.workoutCategories == null || workout.workoutCategories!.isEmpty
          ? CommonUI.getTextButton(ButtonDetails(
              onTap: () => onAddCategoryClick([]),
              text: 'Add Categories',
              style: ButtonDetailsStyle(padding: EdgeInsets.zero),
            ))
          : getWorkoutCategoriesWidget(workout.workoutCategories!, existingCategoryIds);

  void onAddExerciseClick(int workoutId) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AddExercisesToWorkout(workoutId: workoutId)))
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

  void finishOrResumeOnTap(BuildContext context, Workout workout, bool resuming) async {
    try {
      var confirmed = await showConfirm(
        context,
        resuming ? 'Resume Workout?' : 'Finish Workout?',
        resuming
            ? 'Are you sure you would like to resume this workout?'
            : 'Are you sure you are finished with this workout?',
      );

      if (!confirmed) return;
      workout.endDate = resuming ? null : DateTime.now();
      final success = await WorkoutModel.updateWorkout(workout);
      if (!success) throw Exception();

      if (!resuming && context.mounted) {
        Navigator.pop(context);
        return;
      }

      reloadState();
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'Failed to ${resuming ? 'resume' : 'finish'} workout.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Workout?>(
      future: workoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        if (!snapshot.hasData || snapshot.data == null) {
          return const DebugScaffold(body: Center(child: Text("Failed to load workout.")));
        }

        final workout = snapshot.data!;
        final categories = workout.getCategories();
        final workoutExercises = workout.getWorkoutExercises();

        workoutIsFinished = workout.isFinished();

        return DebugScaffold(
          customAppBarTitle: const SizedBox.shrink(),
          customAppBarActions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => showMoreMenu(workout),
            )
          ],
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.getWorkoutTitle(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      CommonUI.getDateWithIcon(context, workout.date),
                      CommonUI.getTimeWithIcon(context, workout.date),
                      workout.isFinished()
                          ? CommonUI.getTimeElapsedWithIcon(context, workout.getDuration())
                          : TimeElapsed(
                              since: workout.date,
                              end: workout.endDate,
                              color: Theme.of(context).colorScheme.shadow,
                            ),
                    ],
                  ),
                  workoutIsFinished
                      ? CommonUI.getElevatedPrimaryButton(
                          ButtonDetails(
                            text: 'Resume',
                            onTap: () => finishOrResumeOnTap(context, workout, true),
                          ),
                        )
                      : CommonUI.getElevatedPrimaryButton(
                          ButtonDetails(
                            text: 'Finish',
                            onTap: () => finishOrResumeOnTap(context, workout, false),
                            style: ButtonDetailsStyle(
                              textColor: Colors.white,
                              backgroundColor: Colors.green[500],
                            ),
                          ),
                        ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(5)),
              getCategoriesWidget(workout, categories),
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CommonUI.getSectionTitle(context, 'Exercises'),
                  Row(children: [
                    RestTimer(workoutId: workout.id),
                    CommonUI.getTextButton(ButtonDetails(
                      icon: Icons.add_rounded,
                      onTap: () => onAddExerciseClick(workout.id!),
                    )),
                  ]),
                ],
              ),
              CommonUI.getDivider(),
              workoutExercises.isEmpty
                  ? Padding(
                      padding: const EdgeInsetsGeometry.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'What are we training today?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Set focus categories for this workout!',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(padding: EdgeInsetsGeometry.all(5)),
                          CommonUI.getElevatedPrimaryButton(ButtonDetails(
                            icon: Icons.add_rounded,
                            text: 'Add an exercise',
                            onTap: () => onAddExerciseClick(workout.id!),
                          )),
                        ],
                      ),
                    )
                  : Expanded(
                      child: ReorderableColumn(
                        onReorder: onWorkoutExerciseReorder,
                        children: getWorkoutExercisesWidget(workout, workoutExercises, workout.exerciseOrdering),
                      ),
                    ),
              const Padding(padding: EdgeInsetsGeometry.all(10)),
            ],
          ),
        );
      },
    );
  }
}
