import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/custom_vertical_divider.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/components/workouts/workout_options_menu.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isDisplay;
  final Function()? reloadParent; // parent needs this class to be stateless for preformance reasons

  const WorkoutCard({
    super.key,
    required this.workout,
    this.isDisplay = false,
    this.reloadParent,
  });

  @override
  Widget build(BuildContext context) {
    final summary = workout.summary;

    void openWorkout({bool autofocusNotes = false, int? focusWe}) => openWorkoutView(
          context,
          workout.id!,
          autofocusNotes: autofocusNotes,
          focusedWorkoutExerciseId: focusWe,
        ).then((x) {
          if (reloadParent != null) reloadParent!();
        });

    List<Widget> getBestSetAndNote() => summary == null
        ? []
        : [
            if (!isDisplay && summary.bestSet != null && summary.bestSetExercise != null)
              Padding(
                padding: const EdgeInsetsGeometry.only(top: 5),
                child: CustomCard(
                  onTap: () => openWorkout(focusWe: summary.bestSet!.workoutExerciseId),
                  color: AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber[300]),
                        const Padding(padding: EdgeInsets.all(5)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(summary.bestSetExercise!.getFullName()),
                            Row(children: [
                              TextWithIcon.weight(summary.bestSet!.weight, muted: true),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                              TextWithIcon.reps(summary.bestSet!.reps, muted: true),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (summary.isNote())
              Padding(
                padding: const EdgeInsetsGeometry.only(top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    summary.note!,
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
          ];

    List<Widget> getESR() => summary == null || summary.totalExercises == 0
        ? []
        : [
            const CustomDivider(shadow: true),
            Container(
              margin: const EdgeInsetsGeometry.only(top: 5),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: summary.totalReps + summary.totalSets == 0
                    ? [
                        Text(
                          summary.getTotalExercisesString(),
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ]
                    : [
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: Text(
                              summary.getTotalExercisesString(),
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                        const CustomVerticalDivider(),
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: Text(
                              summary.getTotalSetsString(),
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                        const CustomVerticalDivider(),
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: Text(
                              summary.getTotalRepsString(),
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                      ],
              ),
            )
          ];

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: openWorkout,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      workout.isFinished() ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: workout.isFinished() ? Theme.of(context).colorScheme.primary : Colors.grey,
                      size: 22,
                    ),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.getWorkoutTitle(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (isDisplay) TextWithIcon.date(workout.date),
                        Row(children: [
                          TextWithIcon.time(workout.date),
                          if (workout.isFinished()) ...[
                            const Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextWithIcon.timeElapsed(workout.getDuration()),
                          ],
                        ]),
                      ],
                    ),
                  ]),
                  WorkoutOptionsMenu(workout: workout, onChange: reloadParent),
                ],
              ),
              if (workout.workoutCategories != null && workout.workoutCategories!.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsGeometry.only(top: 5),
                  child: Row(children: [
                    Expanded(
                      child: Wrap(
                        children: workout
                            .getCategories()
                            .map((c) => PropDisplay(
                                  text: c.displayName,
                                  color: AppHelper.isDarkMode(context) ? AppHelper.darkPropOnCardColor : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ]),
                ),
              ...getBestSetAndNote(),
              if (!isDisplay)
                Padding(
                  padding: const EdgeInsetsGeometry.only(top: 10),
                  child: Row(children: [
                    if (workout.summary == null || !workout.summary!.isNote())
                      Padding(
                        padding: const EdgeInsetsGeometry.only(right: 20),
                        child: Button(
                          text: 'Add Note',
                          icon: Icons.add_rounded,
                          style: ButtonCustomStyle.noPadding(),
                          onTap: () => openWorkout(autofocusNotes: true),
                        ),
                      ),
                    Button(
                      text: 'Add Progress Pic',
                      icon: Icons.add_rounded,
                      style: ButtonCustomStyle.noPadding(),
                      onTap: () => null,
                    ),
                  ]),
                ),
              ...getESR(),
            ],
          ),
        ),
      ),
    );
  }
}
