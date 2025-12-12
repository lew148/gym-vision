import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/confetti_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/workout_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workouts/workout_category_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/providers/global/navigation_provider.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
import 'package:gymvision/providers/history_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/custom_reorderable_list.dart';
import 'package:gymvision/widgets/components/rest_timer.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:gymvision/widgets/components/workouts/workout_exercise_widget.dart';
import 'package:gymvision/widgets/components/workouts/workout_options_menu.dart';
import 'package:gymvision/widgets/components/workouts/summary/sharable_workout_summary.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/pages/homepages/exercises/exercises.dart';
import 'package:gymvision/widgets/pages/homepages/progress/templates.dart';
import 'package:provider/provider.dart';
import 'package:gymvision/providers/workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/forms/fields/category_picker.dart';
import 'package:gymvision/widgets/components/notes.dart';

class WorkoutViewBody extends StatelessWidget {
  static const workoutResumableForHours = 4;

  final bool autofocusNotes;

  const WorkoutViewBody({
    super.key,
    this.autofocusNotes = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final workout = provider.workout;

    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (workout == null) {
      return Column(children: [
        Row(children: [
          Button(
            icon: Icons.keyboard_arrow_down_rounded,
            style: ButtonCustomStyle(padding: const EdgeInsets.symmetric(vertical: 10), iconSize: 30),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Button(
            icon: Icons.refresh_rounded,
            onTap: provider.reload,
          ),
        ]),
        const CustomDivider(shadow: true),
        const Padding(padding: EdgeInsetsGeometry.all(20)),
        SplashText.notFound(item: 'workout'),
      ]);
    }

    final workoutExercises = OrderingHelper.sortByOrder(workout.getWorkoutExercises(), workout.exerciseOrder);
    final categories = workout.getCategories();

    void onFinishOrResumeTap(bool resuming) async {
      try {
        var confirmed = await DialogHelper.showConfirm(
          context,
          title: resuming ? 'Resume Workout?' : 'Finish Workout?',
          content: resuming
              ? 'Are you sure you would like to resume this workout?'
              : 'Are you sure you are finished with this workout?',
        );

        final bool wasActiveWorkout =
            context.mounted ? await context.read<ActiveWorkoutProvider>().isActiveWorkout(workout.id!) : false;

        if (!confirmed) return;
        workout.endDate = resuming ? null : DateTime.now();
        final success = await WorkoutModel.update(workout);
        if (!success) throw Exception();

        if (!resuming) {
          if (context.mounted && wasActiveWorkout) await context.read<RestTimerProvider>().clearTimer();
          if (context.mounted) {
            Navigator.pop(context);
            ConfettiHelper.straightUp(context);
            await BottomSheetHelper.showCloseableBottomSheet(context, SharableWorkoutSummary(workoutId: workout.id!));
          }

          return;
        }

        provider.reload();
      } catch (e) {
        if (context.mounted) AppHelper.showSnackBar(context, 'Failed to ${resuming ? 'resume' : 'finish'} workout.');
      }
    }

    Future<void> onCategoryPillTap(WorkoutCategory wc) async {
      context.read<HistoryProvider>().setCategoryFilters([wc.category]);
      context.read<NavigationProvider>().toHistoryTab();
      Navigator.pop(context); // close workout
    }

    Future<void> onAddCategoryClick(List<Category> existingWorkoutCategoryIds) async =>
        await BottomSheetHelper.showCloseableBottomSheet(
          context,
          CategoryPicker(
            selectedCategories: existingWorkoutCategoryIds,
            onChange: (List<Category> newCategories) async {
              try {
                await WorkoutCategoryModel.setWorkoutCategories(workout.id!, newCategories);
                provider.reload();
              } catch (ex) {
                if (context.mounted) AppHelper.showSnackBar(context, 'Failed to add Categories to workout.');
              }
            },
          ),
        );

    Future<void> onAddExerciseClick() async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DebugScaffold(
            ignoreDefaults: false,
            body: Exercises(
              filterCategories: workout.getCategories(),
              excludedExerciseIdentifiers: workout.getWorkoutExercises().map((we) => we.exerciseIdentifier).toList(),
              onAddTap: (String exerciseIdentifier) async {
                try {
                  await WorkoutExerciseModel.insert(
                    WorkoutExercise(
                      workoutId: workout.id!,
                      exerciseIdentifier: exerciseIdentifier,
                      setOrder: '',
                    ),
                  );
                } catch (ex) {
                  if (context.mounted) AppHelper.showSnackBar(context, 'Failed to add set(s) to workout');
                } finally {
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      );

      provider.reload();
    }

    Future<void> onCopyPreviousWorkoutTap() => BottomSheetHelper.showCloseableBottomSheet(
        context,
        Column(children: [
          Button.elevated(
            text: 'Last Similar Workout',
            onTap: () async {
              Navigator.pop(context);
              final success = await WorkoutModel.copyLastSimilarWorkout(workout.id!, categories);
              if (success) {
                provider.reload();
                return;
              }

              if (context.mounted) AppHelper.showSnackBar(context, 'There is nothing to copy');
            },
          ),
          Button.elevated(
            text: 'Last Workout',
            onTap: () async {
              Navigator.pop(context);
              final success = await WorkoutModel.copyLastWorkout(workout.id!);
              if (success) {
                provider.reload();
                return;
              }

              if (context.mounted) AppHelper.showSnackBar(context, 'There is nothing to copy');
            },
          ),
        ]));

    Future onCreateFromTemplateTap() async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Templates(
            filterCategories: workout.getCategories(),
            onAddTap: (int templateId) async {
              try {
                await WorkoutHelper.copyTemplateToworkout(workoutId: workout.id!, templateId: templateId);
                if (context.mounted) Navigator.pop(context);
                provider.reload();
              } catch (ex) {
                if (context.mounted) AppHelper.showSnackBar(context, 'Failed to copy Template');
              }
            },
          ),
        ),
      );

      provider.reload();
    }

    void onWorkoutExerciseReorder(int currentIndex, int newIndex) async {
      workout.exerciseOrder = OrderingHelper.reorderByIndex(workout.exerciseOrder, currentIndex, newIndex);
      await WorkoutModel.update(workout);
    }

    return Column(
      children: [
        // drop, timer and options
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
              Button(icon: Icons.refresh, onTap: provider.reload),
              if (!workout.isFinished()) const RestTimer(),
            ]),
            Row(children: [
              if (!DateTimeHelper.isInFuture(workout.date) && !workout.isFinished())
                Button.check(onTap: () => onFinishOrResumeTap(false)),
              WorkoutOptionsMenu(
                workout: workout,
                onChange: () => provider.reload(),
                fromWorkoutView: true,
                extraButtons: [
                  if (workout.isFinished() &&
                      DateTime.now().isBefore(workout.endDate!.add(const Duration(hours: workoutResumableForHours))))
                    Button(
                      icon: Icons.play_circle_outline_rounded,
                      text: 'Resume Workout',
                      onTap: () {
                        Navigator.pop(context);
                        onFinishOrResumeTap(true);
                      },
                      style: ButtonCustomStyle.primaryIconOnly(),
                    ),
                ],
              ),
            ]),
          ],
        ),

        // summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatDisplay.date(workout.date, muted: false),
                StatDisplay.time(workout.date, dtEnd: workout.endDate),
                workout.isFinished()
                    ? StatDisplay.timeElapsed(workout.getDuration())
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

        // categories, notes and actions
        if (workout.hasCategories())
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                  alignment: WrapAlignment.start,
                  children: workout.workoutCategories! //todo: sort
                      .map((wc) => PropDisplay(
                            text: wc.getCategoryDisplayName(),
                            onTap: () => onCategoryPillTap(wc),
                            size: PropDisplaySize.small,
                          ))
                      .toList()),
            ],
          ),
        Row(children: [
          Expanded(child: Notes(type: NoteType.workout, objectId: workout.id!.toString(), autofocus: autofocusNotes)),
          Row(children: [
            Button(icon: Icons.category_rounded, onTap: () => onAddCategoryClick(categories)),
            Button(icon: Icons.add_rounded, onTap: onAddExerciseClick),
          ]),
        ]),

        // exercises
        Expanded(
          child: workoutExercises.isEmpty
              ? Padding(
                  padding: const EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0), // b is 0 to avoid padding using keyboard
                  child: Column(
                    children: [
                      const SplashText(
                        title: 'What are you training today?',
                        description: 'One workout closer to your goals!',
                      ),
                      if (!workout.hasCategories()) ...[
                        Button.elevated(
                          icon: Icons.category_rounded,
                          text: 'Select categories',
                          onTap: () => onAddCategoryClick(categories),
                        ),
                        Button.elevated(icon: Icons.add_rounded, text: 'Add exercises', onTap: onAddExerciseClick),
                        Padding(
                          padding: const EdgeInsetsGeometry.all(5),
                          child: Text(
                            'OR',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      Button.elevated(icon: Icons.copy_rounded, text: 'Copy Workout', onTap: onCopyPreviousWorkoutTap),
                      Button.elevated(
                        icon: Icons.description_rounded,
                        text: 'Create from Template',
                        onTap: onCreateFromTemplateTap,
                      ),
                    ],
                  ),
                )
              : CustomReorderableList(
                  key: ValueKey(workoutExercises.length),
                  onReorder: onWorkoutExerciseReorder,
                  children: workoutExercises
                      .map((we) => WorkoutExerciseWidget(
                            key: ValueKey(we.id),
                            workoutExercise: we,
                            onDelete: (x) => provider.reload(),
                            isInFuture: workout.isInFuture(),
                            dropped: provider.droppedWorkoutExerciseIds.contains(we.id),
                            onDrop: (weId) => provider.toggleDroppedExercise(weId),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
