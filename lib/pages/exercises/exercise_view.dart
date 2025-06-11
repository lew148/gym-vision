import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/classes/db/workout_set.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/exercises/exercise_recent_uses_view.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
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

  Widget getNotesDisplay(ExerciseDetails? details) {
    if (details == null) return const SizedBox.shrink();

    var controller = TextEditingController(text: details.notes);

    return Row(
      children: [
        Expanded(
          child: CommonUI.getCard(
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 5),
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Notes',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.shadow)),
                onEditingComplete: () async {
                  try {
                    var newValue = controller.text;
                    if (details.notes == newValue) return;
                    details.notes = newValue;
                    // await UserExerciseDetailsHelper.updateUserExerciseDetails(details);
                  } catch (ex) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit Notes')));
                  }

                  reloadState();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

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
      return workout != null && dateIsInFuture(workout.date);
    });

    if (recentUses.isEmpty) return getNoRecentUsesWidget();

    recentUses.sort(((a, b) => b.getWorkout()!.date.compareTo(a.getWorkout()!.date)));

    final Map<int, List<WorkoutSet>> setsGroupedByWorkoutExercise =
        groupBy<WorkoutSet, int>(recentUses, (x) => x.workoutExerciseId);

    List<Widget> weWidgets = [];
    setsGroupedByWorkoutExercise.forEach((key, value) {
      weWidgets.add(
        GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => WorkoutView(workoutId: value[0].getWorkout()!.id!)))
              .then((value) => reloadState()),
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

  Widget getPrSection(ExerciseDetails? details) => details == null || details.pr == null
      // todo: set pr manually here?
      ? CommonUI.getCard(
          Padding(
            padding: const EdgeInsetsGeometry.all(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('PR'),
              CommonUI.getDash(),
            ]),
          ),
        )
      : GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => WorkoutView(workoutId: details.pr!.getWorkout()!.id!)))
              .then((value) => reloadState()),
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'PR (${details.pr!.getWorkout()!.getDateStr()})',
                style: TextStyle(color: Theme.of(context).colorScheme.shadow),
              ),
              Row(
                children: [
                  CommonUI.getWeightWithIcon(details.pr!),
                  const Padding(padding: EdgeInsets.all(5)),
                  CommonUI.getRepsWithIcon(details.pr!),
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
              if (exercise.type == ExerciseType.strength) getPrSection(details),
              // getNotesDisplay(details),
              CommonUI.getDefaultDivider(),
              CommonUI.getSectionTitle(context, 'History'),
              getRecentUsesWidget(exercise, details),
            ],
          ),
        );
      },
    );
  }
}
