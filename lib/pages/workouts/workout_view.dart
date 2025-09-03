import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/common/components/notes.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/components/debug_scaffold.dart';
import 'package:gymvision/pages/workouts/rest_timer.dart';
import 'package:gymvision/common/forms/category_picker.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/common/forms/add_exercises_to_workout.dart';
import 'package:gymvision/pages/workouts/time_elapsed_widget.dart';
import 'package:gymvision/pages/workouts/workout_exercise_widget.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:reorderables/reorderables.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final bool autofocusNotes;
  final Function? reloadParent;

  const WorkoutView({
    super.key,
    required this.workoutId,
    this.autofocusNotes = false,
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
    workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withWorkoutExercises: true);
  }

  void reloadState() => setState(() {
        workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withWorkoutExercises: true);
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

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) => Expanded(
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
      );

  List<Widget> getWorkoutExercisesWidget(Workout workout, List<WorkoutExercise> workoutExercises) =>
      OrderingHelper.orderListById(workoutExercises, workout.exerciseOrder)
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

  void showEditDate(Workout workout) => showDateTimePicker(
        context,
        initialDateTime: workout.date,
        CupertinoDatePickerMode.date,
        (DateTime dt) async {
          try {
            workout.date = DateTime(dt.year, dt.month, dt.day, workout.date.hour, workout.date.minute);
            await WorkoutModel.update(workout);
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
            workout.date = DateTime(workout.date.year, workout.date.month, workout.date.day, dt.hour, dt.minute);
            await WorkoutModel.update(workout);
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
                () => WorkoutModel.delete(workout.id!),
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

  void onAddExerciseClick(int workoutId) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AddExercisesToWorkout(workoutId: workoutId)))
      .then((x) => reloadState());

  void onWorkoutExerciseReorder(Workout workout, int currentIndex, int newIndex) async {
    try {
      HapticFeedback.mediumImpact();
      workout.exerciseOrder = OrderingHelper.reorderByIndex(workout.exerciseOrder, currentIndex, newIndex);
      await WorkoutModel.update(workout);
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
      final success = await WorkoutModel.update(workout);
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
          customAppBarTitle: const Text(
            'Workout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
                              backgroundColor: const Color.fromARGB(255, 45, 121, 45),
                            ),
                          ),
                        ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                child: Notes(
                  type: NoteType.workout,
                  objectId: workout.id!.toString(),
                  autofocus: widget.autofocusNotes,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  workout.hasCategories()
                      ? getWorkoutCategoriesWidget(workout.workoutCategories!, categories)
                      : CommonUI.getSectionTitle(context, 'Exercises'),
                  Row(children: [
                    RestTimer(workoutId: workout.id),
                    CommonUI.getTextButton(ButtonDetails(
                      icon: Icons.category_rounded,
                      onTap: () => onAddCategoryClick(categories),
                    )),
                    CommonUI.getTextButton(ButtonDetails(
                      icon: Icons.add_rounded,
                      onTap: () => onAddExerciseClick(workout.id!),
                    )),
                  ]),
                ],
              ),
              CommonUI.getDivider(),
              Expanded(
                child: workoutExercises.isEmpty
                    ? Padding(
                        padding: const EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'What are you training today?',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'One workout closer to your goals!',
                                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                                textAlign: TextAlign.center,
                              ),
                              const Padding(padding: EdgeInsetsGeometry.all(5)),
                              if (!workout.hasCategories()) ...[
                                CommonUI.getElevatedPrimaryButton(ButtonDetails(
                                  icon: Icons.category_rounded,
                                  text: 'Select categories',
                                  onTap: () => onAddCategoryClick(categories),
                                )),
                                Padding(
                                  padding: const EdgeInsetsGeometry.all(5),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.shadow),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              CommonUI.getElevatedPrimaryButton(ButtonDetails(
                                icon: Icons.add_rounded,
                                text: 'Add exercises',
                                onTap: () => onAddExerciseClick(workout.id!),
                              )),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsetsGeometry.only(bottom: 10),
                        child: ReorderableColumn(
                          onReorder: (i1, i2) => onWorkoutExerciseReorder(workout, i1, i2),
                          children: getWorkoutExercisesWidget(workout, workoutExercises),
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
