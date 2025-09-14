import 'package:collection/collection.dart';
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
import 'package:gymvision/widgets/pages/exercise/exercise_recent_uses_view.dart';
import 'package:gymvision/widgets/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

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

  Widget getNoRecentUsesWidget() => const Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text('No recent uses of this exercise.'),
        ),
      );

  Widget getRecentUsesWidget(Exercise exercise, ExerciseDetails? details) {
    if (details == null || (details.recentUses?.isEmpty ?? true)) return getNoRecentUsesWidget();

    final recentUses = details.recentUses!;
    recentUses.removeWhere((ws) {
      final workout = ws.getWorkout();
      return workout != null && DateTimeHelper.isInFuture(workout.date);
    });

    if (recentUses.isEmpty) return getNoRecentUsesWidget();

    recentUses.sort(((a, b) => b.getWorkout()!.date.compareTo(a.getWorkout()!.date)));

    final Map<int, List<WorkoutSet>> setsGroupedByWorkoutExercise =
        groupBy<WorkoutSet, int>(recentUses, (x) => x.workoutExerciseId);

    List<Widget> weWidgets = [];
    setsGroupedByWorkoutExercise.forEach((key, value) {
      weWidgets.add(
        GestureDetector(
          onTap: () => openWorkoutView(context, value[0].getWorkout()!.id!, reloadState: reloadState),
          child: ExerciseRecentUsesView(workoutSets: value, exercise: exercise),
        ),
      );
    });

    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: weWidgets,
          ),
        ),
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
              style: TextStyle(color: Theme.of(context).colorScheme.shadow),
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
              CommonUI.getDivider(),
              CommonUI.getSectionTitle(context, 'History'),
              getRecentUsesWidget(exercise, details),
            ],
          ),
        );
      },
    );
  }
}
