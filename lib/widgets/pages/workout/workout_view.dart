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
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/pages/workout/workout_exercise_widget.dart';
import 'package:gymvision/widgets/forms/category_picker.dart';
import 'package:gymvision/widgets/forms/add_exercises_to_workout.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/pages/workout/workout_options_menu.dart';
import 'package:reorderables/reorderables.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final bool autofocusNotes;
  final List<int>? droppedWes;

  const WorkoutView({
    super.key,
    required this.workoutId,
    this.autofocusNotes = false,
    this.droppedWes,
  });

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  late Future<Workout?> workoutFuture;
  late List<int> droppedWes;

  @override
  void initState() {
    super.initState();
    workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withExercises: true);
    droppedWes = widget.droppedWes ?? [];
  }

  void reload() => setState(() {
        workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withExercises: true);
      });

  void onCategoriesChange(List<Category> newCategories) async {
    try {
      await WorkoutCategoryModel.setWorkoutCategories(widget.workoutId, newCategories);
      reload();
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

    openWorkoutView(context, id, onClose: reload);
  }

  getWorkoutCategoriesWidget(List<WorkoutCategory> workoutCategories, List<Category> existingCategories) => Wrap(
        alignment: WrapAlignment.start,
        children: workoutCategories //todo: sort
            .map((wc) => PropDisplay(
                  text: wc.getCategoryDisplayName(),
                  onTap: () => goToMostRecentWorkout(wc),
                  size: PropDisplaySize.small,
                ))
            .toList(),
      );

  List<Widget> getWorkoutExercisesWidget(Workout workout, List<WorkoutExercise> workoutExercises) =>
      OrderingHelper.orderListById(workoutExercises, workout.exerciseOrder)
          .map((we) => Container(
                key: Key(we.id.toString()),
                child: WorkoutExerciseWidget(
                  workoutExercise: we,
                  onDelete: (x) => reload(),
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

  void onAddExerciseClick(int workoutId) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AddExercisesToWorkout(workoutId: workoutId)))
      .then((x) => reload());

  void onCopyPreviousWorkoutTap(int workoutId, List<Category> categories) => showCloseableBottomSheet(
      context,
      Column(children: [
        Button(
          elevated: true,
          text: 'Last Similar Workout',
          onTap: () async {
            Navigator.pop(context);
            final success = await WorkoutModel.copyLastSimilarWorkout(workoutId, categories);
            if (success) {
              reload();
              return;
            }

            if (mounted) showSnackBar(context, 'There is nothing to copy');
          },
        ),
        Button(
          elevated: true,
          text: 'Last Workout',
          onTap: () async {
            Navigator.pop(context);
            final success = await WorkoutModel.copyLastWorkout(workoutId);
            if (success) {
              reload();
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

    reload();
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

      reload();
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
              Button(
                icon: Icons.keyboard_arrow_down_rounded,
                style: ButtonCustomStyle(padding: const EdgeInsets.symmetric(vertical: 10), iconSize: 30),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ]),
            const CustomDivider(shadow: true),
            const Padding(padding: EdgeInsetsGeometry.all(20)),
            SplashText.notFound(item: 'workout'),
          ]);
        }

        final workout = snapshot.data!;
        final categories = workout.getCategories();
        final workoutExercises = workout.getWorkoutExercises();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Button(
                    icon: Icons.keyboard_arrow_down_rounded,
                    style: ButtonCustomStyle(padding: const EdgeInsets.symmetric(vertical: 10), iconSize: 30),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const RestTimer(),
                ]),
                Row(children: [
                  if (!DateTimeHelper.isInFuture(workout.date) && !workout.isFinished())
                    Button(icon: Icons.check_rounded, onTap: () => onFinishOrResumeTap(context, workout, false)),
                  WorkoutOptionsMenu(
                    workout: workout,
                    onChange: reload,
                    popCallerOnDelete: true,
                    extraButtons: [
                      if (workout.isFinished())
                        Button(
                          icon: Icons.play_circle_outline_rounded,
                          text: 'Resume Workout',
                          onTap: () {
                            Navigator.pop(context);
                            onFinishOrResumeTap(context, workout, true);
                          },
                          style: ButtonCustomStyle.primaryIconOnly(),
                        ),
                      Button(
                        onTap: () {
                          Navigator.pop(context);
                          showDateTimePicker(
                            context,
                            initialDateTime: workout.date,
                            CupertinoDatePickerMode.date,
                            (DateTime dt) async {
                              try {
                                workout.date = DateTime(
                                  dt.year,
                                  dt.month,
                                  dt.day,
                                  workout.date.hour,
                                  workout.date.minute,
                                  workout.date.second,
                                );
                                await WorkoutModel.update(workout);
                                reload();
                              } catch (ex) {
                                // do nothing
                              }
                            },
                          );
                        },
                        style: ButtonCustomStyle.primaryIconOnly(),
                        icon: Icons.calendar_today_rounded,
                        text: 'Change Date',
                      ),
                    ],
                  ),
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
                    TextWithIcon.date(workout.date, muted: false),
                    TextWithIcon.time(workout.date, dtEnd: workout.endDate),
                    workout.isFinished()
                        ? TextWithIcon.timeElapsed(workout.getDuration())
                        : TimeElapsed(
                            since: workout.date,
                            end: workout.endDate,
                            color: Theme.of(context).colorScheme.secondary,
                            labelForNegativeDuration: 'Starts in',
                          ),
                  ],
                ),
              ],
            ),
            if (workout.hasCategories())
              Row(children: [getWorkoutCategoriesWidget(workout.workoutCategories!, categories)]),
            Row(children: [
              Expanded(
                child: Notes(
                  type: NoteType.workout,
                  objectId: workout.id!.toString(),
                  autofocus: widget.autofocusNotes,
                ),
              ),
              Row(children: [
                Button(
                  icon: Icons.category_rounded,
                  onTap: () => onAddCategoryClick(categories),
                ),
                Button(
                  icon: Icons.add_rounded,
                  onTap: () => onAddExerciseClick(workout.id!),
                ),
              ]),
            ]),
            Expanded(
              child: workoutExercises.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0), // b is 0 to avoid padding using keyboard
                      child: Column(
                        children: [
                          const SplashText(
                            title: 'What are you training today?',
                            description: 'One workout closer to your goals!',
                          ),
                          if (!workout.hasCategories()) ...[
                            Button(
                              icon: Icons.category_rounded,
                              text: 'Select categories',
                              onTap: () => onAddCategoryClick(categories),
                              elevated: true,
                            ),
                            Padding(
                              padding: const EdgeInsetsGeometry.all(5),
                              child: Text(
                                'OR',
                                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          Button(
                            icon: Icons.add_rounded,
                            text: 'Add exercises',
                            onTap: () => onAddExerciseClick(workout.id!),
                            elevated: true,
                          ),
                          Button(
                            icon: Icons.copy_rounded,
                            text: 'Copy Workout',
                            onTap: () => onCopyPreviousWorkoutTap(workout.id!, categories),
                            elevated: true,
                          ),
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
