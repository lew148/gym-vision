import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/widgets/components/notes.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/rest_timer.dart';
import 'package:gymvision/widgets/pages/workout/workout_exercise_widget.dart';
import 'package:gymvision/widgets/forms/category_picker.dart';
import 'package:gymvision/widgets/common/common_ui.dart';
import 'package:gymvision/widgets/forms/add_exercises_to_workout.dart';
import 'package:gymvision/widgets/components/time_elapsed_widget.dart';
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

  void onAddCategoryClick(List<Category> existingWorkoutCategoryIds) => showCloseableBottomSheet(
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

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) => Wrap(
        alignment: WrapAlignment.start,
        children: workoutCategories //todo: sort
            .map((wc) => CommonUI.getSmallPropDisplay(
                  context,
                  wc.getCategoryDisplayName(),
                  onTap: () => goToMostRecentWorkout(wc),
                ))
            .toList(),
      );

  List<Widget> getWorkoutExercisesWidget(Workout workout, List<WorkoutExercise> workoutExercises) =>
      OrderingHelper.orderListById(workoutExercises, workout.exerciseOrder)
          .map((we) => Container(
                key: Key(we.id.toString()),
                child: WorkoutExerciseWidget(
                  workoutExercise: we,
                  onDelete: (x) => reloadState(),
                  toggleDroppedParent: (int? weId) {
                    if (weId != null) {
                      droppedWes.contains(weId) ? droppedWes.remove(weId) : droppedWes.add(weId);
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
            workout.date =
                DateTime(dt.year, dt.month, dt.day, workout.date.hour, workout.date.minute, workout.date.second);
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
            workout.date =
                DateTime(workout.date.year, workout.date.month, workout.date.day, dt.hour, dt.minute, dt.second);
            await WorkoutModel.update(workout);
            reloadState();
          } catch (ex) {
            // do nothing
          }
        },
      );

  void showEditEndTime(Workout workout) => showDateTimePicker(
        context,
        initialDateTime: workout.endDate,
        CupertinoDatePickerMode.dateAndTime,
        (DateTime dt) async {
          try {
            workout.endDate = dt;
            await WorkoutModel.update(workout);
            reloadState();
          } catch (ex) {
            // do nothing
          }
        },
      );

  void showMoreMenu(Workout workout, bool workoutIsFinished) => showOptionsMenu(
        context,
        [
          //   ButtonDetails(
          //     onTap: () async {
          //       Navigator.pop(context);

          //       try {
          //         final exportString = await WorkoutModel.getWorkoutExportString(workout.id!);
          //         if (exportString == null) throw Exception();
          //         await Clipboard.setData(ClipboardData(text: exportString));
          //         if (mounted) showSnackBar(context, 'Workout copied to clipboard!');
          //       } catch (ex) {
          //         if (mounted) showSnackBar(context, 'Failed to export workout.');
          //       }
          //     },
          //     icon: Icons.share_rounded,
          //     text: 'Export Workout',
          //   ),
          if (workoutIsFinished) ...[
            ButtonDetails(
              icon: Icons.play_circle_outline_rounded,
              text: 'Resume Workout',
              onTap: () => onFinishOrResumeTap(context, workout, true),
              style: ButtonDetailsStyle.primaryIcon(context),
            ),
            ButtonDetails(
              onTap: () {
                Navigator.pop(context);
                showEditEndTime(workout);
              },
              icon: Icons.access_time_rounded,
              style: ButtonDetailsStyle.primaryIcon(context),
              text: 'Change End Time',
            ),
          ],
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showEditDate(workout);
            },
            style: ButtonDetailsStyle.primaryIcon(context),
            icon: Icons.calendar_today_rounded,
            text: 'Change Date',
          ),
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showEditTime(workout);
            },
            icon: Icons.access_time_rounded,
            style: ButtonDetailsStyle.primaryIcon(context),
            text: 'Change Start Time',
          ),
          ButtonDetails(
            onTap: () {
              Navigator.pop(context);
              showDeleteConfirm(
                context,
                "workout",
                () async => deleteWorkout(context, workout.id!),
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

  void onCopyPreviousWorkoutTap(int workoutId, List<Category> categories) => showCloseableBottomSheet(
      context,
      CommonUI.getElevatedButtonsMenu(context, [
        ButtonDetails(
          text: 'Last Similar Workout',
          onTap: () async {
            Navigator.pop(context);
            final success = await WorkoutModel.copyLastSimilarWorkout(workoutId, categories);
            if (success) {
              reloadState();
              return;
            }

            if (mounted) showSnackBar(context, 'There is nothing to copy');
          },
        ),
        ButtonDetails(
          text: 'Last Workout',
          onTap: () async {
            Navigator.pop(context);
            final success = await WorkoutModel.copyLastWorkout(workoutId);
            if (success) {
              reloadState();
              return;
            }

            if (mounted) showSnackBar(context, 'There is nothing to copy');
          },
        ),
      ]));

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

  void onFinishOrResumeTap(BuildContext context, Workout workout, bool resuming) async {
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
          return Column(children: [
            Row(children: [
              CommonUI.getTextButton(ButtonDetails(
                icon: Icons.keyboard_arrow_down_rounded,
                style: ButtonDetailsStyle(padding: const EdgeInsets.symmetric(vertical: 10), iconSize: 30),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
            ]),
            const Padding(padding: EdgeInsetsGeometry.all(20)),
            Center(
              child: Column(children: [
                Icon(
                  Icons.fmd_bad_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Padding(padding: EdgeInsetsGeometry.all(10)),
                const Text(
                  "Failed to load workout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ]),
            ),
          ]);
        }

        final workout = snapshot.data!;
        final categories = workout.getCategories();
        final workoutExercises = workout.getWorkoutExercises();
        workoutIsFinished = workout.isFinished();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  CommonUI.getTextButton(ButtonDetails(
                    icon: Icons.keyboard_arrow_down_rounded,
                    style: ButtonDetailsStyle(padding: const EdgeInsets.symmetric(vertical: 10), iconSize: 30),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )),
                  const RestTimer(),
                ]),
                Row(children: [
                  if (!DateTimeHelper.isInFuture(workout.date) && !workoutIsFinished)
                    CommonUI.getTextButton(
                      ButtonDetails(
                        icon: Icons.check_rounded,
                        onTap: () => onFinishOrResumeTap(context, workout, false),
                      ),
                    ),
                  CommonUI.getTextButton(ButtonDetails(
                    onTap: () => showMoreMenu(workout, workoutIsFinished),
                    icon: Icons.more_vert_rounded,
                  )),
                ]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUI.getDateWithIcon(context, workout.date),
                    CommonUI.getTimeWithIcon(context, workout.date, dtEnd: workout.endDate),
                    workout.isFinished()
                        ? CommonUI.getTimeElapsedWithIcon(context, workout.getDuration())
                        : TimeElapsed(
                            since: workout.date,
                            end: workout.endDate,
                            color: Theme.of(context).colorScheme.shadow,
                            labelForNegativeDuration: 'Starts in',
                          ),
                  ],
                ),
              ],
            ),
            if (workout.hasCategories())
              Row(children: [
                getWorkoutCategoriesWidget(workout.workoutCategories!, categories),
              ]),
            Row(children: [
              Expanded(
                child: Notes(
                  type: NoteType.workout,
                  objectId: workout.id!.toString(),
                  autofocus: widget.autofocusNotes,
                ),
              ),
              Row(children: [
                CommonUI.getTextButton(ButtonDetails(
                  icon: Icons.category_rounded,
                  onTap: () => onAddCategoryClick(categories),
                )),
                CommonUI.getTextButton(ButtonDetails(
                  icon: Icons.add_rounded,
                  onTap: () => onAddExerciseClick(workout.id!),
                )),
              ]),
            ]),
            Expanded(
              child: workoutExercises.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0), // b is 0 to avoid padding using keyboard
                      child: Column(
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
                          const Padding(padding: EdgeInsetsGeometry.all(10)),
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
                          CommonUI.getElevatedPrimaryButton(ButtonDetails(
                            icon: Icons.copy_rounded,
                            text: 'Copy Workout',
                            onTap: () => onCopyPreviousWorkoutTap(workout.id!, categories),
                          )),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ReorderableColumn(
                        padding: const EdgeInsets.only(bottom: 20),
                        onReorder: (i1, i2) => onWorkoutExerciseReorder(workout, i1, i2),
                        children: getWorkoutExercisesWidget(workout, workoutExercises),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
