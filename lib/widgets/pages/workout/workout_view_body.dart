import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/rest_timer.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/components/time_elapsed.dart';
import 'package:gymvision/widgets/forms/add_exercises_to_workout.dart';
import 'package:gymvision/widgets/components/workouts/workout_options_menu.dart';
import 'package:gymvision/widgets/components/workouts/sharable_workout_summary.dart';
import 'package:provider/provider.dart';
import 'package:gymvision/providers/workout_provider.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/workouts/workout_exercise_widget.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/forms/category_picker.dart';
import 'package:gymvision/helpers/common_functions.dart';
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

    final workoutExercises = OrderingHelper.orderListById(workout.getWorkoutExercises(), workout.exerciseOrder);
    final categories = workout.getCategories();

    void onFinishOrResumeTap(bool resuming) async {
      try {
        var confirmed = await showConfirm(
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
            Confetti.launch(context, options: const ConfettiOptions(particleCount: 200, spread: 70, y: 0.8));
            await showCloseableBottomSheet(context, SharableWorkoutSummary(workoutId: workout.id!));
          }

          return;
        }

        provider.reload();
      } catch (e) {
        if (context.mounted) showSnackBar(context, 'Failed to ${resuming ? 'resume' : 'finish'} workout.');
      }
    }

    Future<void> goToMostRecentWorkout(WorkoutCategory wc) async {
      var id = await WorkoutModel.getMostRecentWorkoutIdForCategory(wc);
      if (!context.mounted) return;

      if (id == null) {
        showSnackBar(context, 'No previous workouts for this category.');
        return;
      }

      await openWorkoutView(context, id);
      provider.reload();
    }

    Future<void> onAddCategoryClick(List<Category> existingWorkoutCategoryIds) async {
      await showCloseableBottomSheet(
        context,
        CateogryPicker(
          selectedCategories: existingWorkoutCategoryIds,
          onChange: (List<Category> newCategories) async {
            try {
              await WorkoutCategoryModel.setWorkoutCategories(workout.id!, newCategories);
            } catch (ex) {
              if (context.mounted) showSnackBar(context, 'Failed to add Categories to workout.');
            }
          },
        ),
      );

      provider.reload();
    }

    Future<void> onAddExerciseClick() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddExercisesToWorkout(workoutId: workout.id!)),
      );

      provider.reload();
    }

    Future<void> onCopyPreviousWorkoutTap() => showCloseableBottomSheet(
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

              if (context.mounted) showSnackBar(context, 'There is nothing to copy');
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

              if (context.mounted) showSnackBar(context, 'There is nothing to copy');
            },
          ),
        ]));

    // void onWorkoutExerciseReorder(int currentIndex, int newIndex) async {
    //   try {
    //     HapticFeedback.heavyImpact();
    //     workout.exerciseOrder = OrderingHelper.reorderByIndex(workout.exerciseOrder, currentIndex, newIndex);
    //     await WorkoutModel.update(workout);
    //   } catch (e) {
    //     // do nothing
    //   }

    //   provider.reload();
    // }

    return Column(
      children: [
        // --- drop, timer and options ---
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
              Button(
                icon: Icons.refresh,
                onTap: provider.reload,
              ),
              if (!workout.isFinished()) const RestTimer(),
            ]),
            Row(children: [
              if (!DateTimeHelper.isInFuture(workout.date) && !workout.isFinished())
                Button(icon: Icons.check_rounded, onTap: () => onFinishOrResumeTap(false)),
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

        // --- summary ---
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

        // --- categories, notes and actions ---
        if (workout.hasCategories())
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                  alignment: WrapAlignment.start,
                  children: workout.workoutCategories! //todo: sort
                      .map((wc) => PropDisplay(
                            text: wc.getCategoryDisplayName(),
                            onTap: () => goToMostRecentWorkout(wc),
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

        // --- exercises ---
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
                          Padding(
                            padding: const EdgeInsetsGeometry.all(5),
                            child: Text(
                              'OR',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        Button.elevated(icon: Icons.add_rounded, text: 'Add exercises', onTap: onAddExerciseClick),
                        Button.elevated(
                            icon: Icons.copy_rounded, text: 'Copy Workout', onTap: onCopyPreviousWorkoutTap),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: workoutExercises.length,
                      itemBuilder: (context, index) {
                        final we = workoutExercises[index];
                        return Container(
                          key: Key(we.id.toString()),
                          child: WorkoutExerciseWidget(
                            workoutExercise: we,
                            onDelete: (x) => provider.reload(),
                            isInFuture: workout.isInFuture(),
                          ),
                        );
                      },
                      // onReorder: onWorkoutExerciseReorder,
                    ),
                  )),
      ],
    );
  }
}
