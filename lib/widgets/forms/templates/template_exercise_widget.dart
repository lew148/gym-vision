import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_set.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/forms/templates/template_set_form.dart';
import 'package:gymvision/widgets/pages/exercise/exercise_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class TemplateExerciseWidget extends StatefulWidget {
  final WorkoutTemplateExercise workoutTemplateExercise;
  final Function(int weId)? onDelete;

  const TemplateExerciseWidget({
    super.key,
    required this.workoutTemplateExercise,
    this.onDelete,
  });

  @override
  State<TemplateExerciseWidget> createState() => _TemplateExerciseWidgetState();
}

class _TemplateExerciseWidgetState extends State<TemplateExerciseWidget> {
  late Future<List<WorkoutTemplateSet>> setsFuture;
  late String exerciseIdentifier;
  late Exercise exercise;
  bool dropped = false;

  @override
  void initState() {
    super.initState();
    exerciseIdentifier = widget.workoutTemplateExercise.exerciseIdentifier;
    setsFuture = WorkoutTemplateModel.getSetsForTemplateExercise(
      widget.workoutTemplateExercise.id!,
    );
    exercise =
        widget.workoutTemplateExercise.exercise ?? DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier)!;
  }

  void reload() => setState(() {
        setsFuture = WorkoutTemplateModel.getSetsForTemplateExercise(
          widget.workoutTemplateExercise.id!,
        );
      });

  Future onEditWorkoutSetTap(WorkoutTemplateSet set) async => await BottomSheetHelper.showCloseableBottomSheet(
        context,
        TemplateSetForm(
          templateId: widget.workoutTemplateExercise.workoutTemplateId,
          exerciseIdentifier: exerciseIdentifier,
          onSuccess: reload,
          templateSet: set,
        ),
      );

  Future onCopySetButtonTap(WorkoutTemplateSet set) async {
    try {
      HapticFeedback.lightImpact();
      await WorkoutTemplateModel.insertWorkoutTemplateSet(
        WorkoutTemplateSet(
          workoutTemplateExerciseId: set.workoutTemplateExerciseId,
          weight: set.weight,
          time: set.time,
          distance: set.distance,
          calsBurned: set.calsBurned,
          reps: set.reps,
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      AppHelper.showSnackBar(context, 'Failed add set to template: ${ex.toString()}');
    }

    reload();
  }

  void onAddSetsButtonTap() async {
    await BottomSheetHelper.showCloseableBottomSheet(
      context,
      TemplateSetForm(
        templateId: widget.workoutTemplateExercise.workoutTemplateId,
        exerciseIdentifier: exerciseIdentifier,
        onSuccess: () {
          setState(() {
            if (!dropped) dropped = true;
            setsFuture = WorkoutTemplateModel.getSetsForTemplateExercise(
              widget.workoutTemplateExercise.id!,
            );
          });
        },
      ),
    );
  }

  Widget getCheckAndIndex(int flex, WorkoutTemplateSet set, int setNumber) => Expanded(
        flex: flex,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
            Text(
              setNumber.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
      );

  List<Widget> getWeightedSetContents(WorkoutTemplateSet set, int setNumber) => [
        getCheckAndIndex(3, set, setNumber),
        Expanded(flex: 4, child: StatDisplay.weight(set.weight, alignment: MainAxisAlignment.start)),
        Expanded(flex: 4, child: StatDisplay.reps(set.reps, alignment: MainAxisAlignment.start)),
      ];

  List<Widget> getCardioSetContents(WorkoutTemplateSet set, int setNumber) => [
        getCheckAndIndex(2, set, setNumber),
        Expanded(flex: 4, child: StatDisplay.duration(set.time, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: StatDisplay.distance(set.distance, alignment: MainAxisAlignment.center)),
        Expanded(flex: 4, child: StatDisplay.caloriesBurned(set.calsBurned, alignment: MainAxisAlignment.center)),
      ];

  Widget getSetWidgetInner(WorkoutTemplateSet set, int setNumber) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: widget.workoutTemplateExercise.isCardio()
              ? getCardioSetContents(set, setNumber)
              : getWeightedSetContents(set, setNumber),
        ),
      );

  List<Widget> getSetWidgets(List<WorkoutTemplateSet> sets) {
    final List<Widget> widgets = [];

    final orderedSets = OrderingHelper.sortByOrder(sets, widget.workoutTemplateExercise.setOrder);
    for (int i = 0; i < orderedSets.length; i++) {
      final set = orderedSets[i];
      widgets.add(InkWell(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
        enableFeedback: false,
        onLongPress: () => OptionsMenu.showOptionsMenu(
          context,
          buttons: [
            Button(
              text: 'Copy Set',
              icon: Icons.content_copy_rounded,
              style: ButtonCustomStyle.primaryIconOnly(),
              onTap: () => onCopySetButtonTap(set),
            ),
            Button(
              text: 'Edit Set',
              icon: Icons.edit_rounded,
              style: ButtonCustomStyle.primaryIconOnly(),
              onTap: () async {
                Navigator.pop(context);
                await onEditWorkoutSetTap(set);
              },
            ),
            Button(
              text: 'Delete Set',
              icon: Icons.delete_rounded,
              style: ButtonCustomStyle.redIconOnly(),
              onTap: () async {
                await DialogHelper.showDeleteConfirm(
                    context, "set", () => WorkoutTemplateModel.deleteWorkoutTemplateSet(set.id!));
                if (mounted) Navigator.pop(context);
                reload();
              },
            ),
          ],
        ),
        onTap: () => onEditWorkoutSetTap(set),
        child: getSetWidgetInner(set, i + 1),
      ));
    }

    return widgets;
  }

  Widget getHeader({required bool standalone, List<WorkoutTemplateSet>? sets}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (exercise.equipment != Equipment.other)
                        Text(
                          exercise.equipment.displayName,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                    ],
                  ),
                ),
                if (!standalone)
                  dropped ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(icon: Icons.add_rounded, onTap: onAddSetsButtonTap),
                OptionsMenu(
                  title: exercise.getFullName(),
                  buttons: [
                    Button(
                      icon: Icons.visibility_rounded,
                      text: 'View Exercise',
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ExerciseView(identifier: exerciseIdentifier)),
                        );

                        reload();
                      },
                      style: ButtonCustomStyle.primaryIconOnly(),
                    ),
                    Button.delete(
                      onTap: () async {
                        Navigator.pop(context);
                        await DialogHelper.showDeleteConfirm(
                          context,
                          "exercise from template",
                          () => WorkoutTemplateModel.deleteWorkoutTemplateExercise(widget.workoutTemplateExercise.id!),
                        );

                        if (widget.onDelete != null) widget.onDelete!(widget.workoutTemplateExercise.id!);
                      },
                      text: 'Delete Exercise',
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setsFuture,
      builder: (context, snapshot) {
        final sets = snapshot.data;
        return ShimmerLoad(
          height: dropped ? 100 : 50,
          loading: snapshot.connectionState == ConnectionState.waiting,
          child: CustomCard(
            child: sets == null || sets.isEmpty
                ? getHeader(standalone: true)
                : Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            dropped = !dropped;
                          });
                        },
                        behavior: HitTestBehavior.translucent,
                        child: getHeader(standalone: false, sets: sets),
                      ),
                      if (dropped) ...[
                        const CustomDivider(shadow: true, height: 0),
                        Column(children: getSetWidgets(sets)),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
