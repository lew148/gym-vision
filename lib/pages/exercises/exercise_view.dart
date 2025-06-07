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

  Widget getNotesDisplay(ExerciseDetails details) => Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => openNotesForm(details),
              child: CommonUI.getCard(
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Flexible(child: Text(details.notes == null ? '-' : details.notes!)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget getExerciseViewWidget(Exercise exercise) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 5),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Wrap(children: [
              if (exercise.type != ExerciseType.other) CommonUI.getPropDisplay(context, exercise.type.displayName),
              if (exercise.primaryMuscleGroup != MuscleGroup.other)
                CommonUI.getPropDisplay(context, exercise.primaryMuscleGroup.displayName),
            ]),
            Wrap(children: [
              if (exercise.equipment != Equipment.other)
                CommonUI.getPropDisplay(context, exercise.equipment.displayName),
            ]),
          ],
        ),
      );

  void openNotesForm(ExerciseDetails details) {
    var controller = TextEditingController(text: details.notes);

    CommonFunctions.showBottomSheet(
      context,
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Edit Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Column(
              children: [
                TextFormField(
                  controller: controller,
                  textInputAction: TextInputAction.go,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add notes here',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CommonUI.getElevatedPrimaryButton(
                        context,
                        ButtonDetails(
                          onTap: () async {
                            Navigator.pop(context);

                            try {
                              var newValue = controller.text;
                              if (details.notes == newValue) return;
                              details.notes = newValue;
                              // await UserExerciseDetailsHelper.updateUserExerciseDetails(details);
                            } catch (ex) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Failed to edit Notes')));
                            }

                            reloadState();
                          },
                          text: 'Save',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
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
      // value.sort(((a, b) => a.createdAt?.compareTo(b.createdAt ?? DateTime.now()) ?? 1));
      weWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WorkoutView(workoutId: value[0].getWorkout()!.id!)))
                .then((value) => reloadState()),
            child: ExerciseRecentUsesView(workoutSets: value, exercise: exercise),
          ),
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

  Widget getPrSection(ExerciseDetails? details) => Column(children: [
        CommonUI.getInfoWidget(
          context,
          'PR',
          details == null || details.pr == null
              ? null
              : Row(
                  children: [
                    // Text(details.pr!.getWorkout()!.getDateStr()),
                    CommonUI.getWeightWithIcon(details.pr!),
                    const Padding(padding: EdgeInsets.all(10)),
                    CommonUI.getRepsWithIcon(details.pr!),
                  ],
                ),
        ),
        CommonUI.getDefaultDivider(),
      ]);

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
              CommonUI.getDefaultDivider(),
              // getExerciseViewWidget(exercise),
              if (exercise.type == ExerciseType.strength) getPrSection(details),
              CommonUI.getSectionTitle(context, 'Recent Uses'),
              CommonUI.getDefaultDivider(),
              getRecentUsesWidget(exercise, details),
            ],
          ),
        );
      },
    );
  }
}
