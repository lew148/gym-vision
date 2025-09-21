import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/widgets/components/notes.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/pages/workout/workout_exercise_widget.dart';

class ExerciseView extends StatefulWidget {
  final String identifier;

  const ExerciseView({
    super.key,
    required this.identifier,
  });

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  late Future<Exercise?> _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = DefaultExercisesModel.getExerciseWithDetails(identifier: widget.identifier, includeRecentUses: true);
  }

  reloadState() => setState(() {});

  Widget getNoUsesWidget() => Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You have not yet used this exercise",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Add this to your next workout?",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget getRecentUsesWidget(Exercise exercise, ExerciseDetails? details) {
    if (details == null || (details.workoutExercises?.isEmpty ?? true)) return getNoUsesWidget();

    final workoutExercises = details.workoutExercises!;
    workoutExercises.removeWhere((we) => we.workout != null && DateTimeHelper.isInFuture(we.workout!.date));
    if (workoutExercises.isEmpty) return getNoUsesWidget();

    workoutExercises.sort(((a, b) => b.workout!.date.compareTo(a.workout!.date)));

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
            children: workoutExercises
                .map((we) => WorkoutExerciseWidget(
                      workoutExercise: we,
                      isDisplay: true,
                    ))
                .toList()),
      ),
    );
  }

  Widget getPrSection(WorkoutSet pr) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openWorkoutView(context, pr.getWorkout()!.id!, reloadState: reloadState),
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'PR (${DateTimeHelper.getDateStr(pr.getWorkout()!.date)})',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            Row(
              children: [
                CommonUI.getWeightWithIcon(pr),
                const Padding(padding: EdgeInsets.all(5)),
                CommonUI.getRepsWithIcon(pr),
              ],
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise?>(
      future: _exercise,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        var exercise = snapshot.data!;
        var details = exercise.exerciseDetails;

        return DebugScaffold(
          ignoreDefaults: true,
          customAppBarTitle: Text(
            exercise.name,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          body: Column(
            children: [
              // if (god)
              CommonUI.getInfoWidget(
                  context,
                  'ID',
                  SelectableText(
                    exercise.identifier,
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                  )),
              CommonUI.getInfoWidget(context, 'Type', Text(exercise.type.displayName)),
              CommonUI.getInfoWidget(context, 'Primary Muscle', Text(exercise.primaryMuscleGroup.displayName)),
              CommonUI.getInfoWidget(context, 'Equipment', Text(exercise.equipment.displayName)),
              if (exercise.type == ExerciseType.strength && details?.pr != null) getPrSection(details!.pr!),
              Notes(type: NoteType.exercise, objectId: exercise.identifier),
              CommonUI.getSectionTitle(context, 'History'),
              CommonUI.getShadowDivider(context),
              getRecentUsesWidget(exercise, details),
            ],
          ),
        );
      },
    );
  }
}
