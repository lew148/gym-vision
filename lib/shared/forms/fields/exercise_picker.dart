import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../db/classes/exercise.dart';

class ExercisePicker extends StatefulWidget {
  final int? exerciseId;
  final Exercise? exercise;
  final List<int>? categoryShellIds;
  final bool autoOpen;
  final Function(Exercise exercise)? onQuickAdd;
  final Function setExercise;

  const ExercisePicker({
    Key? key,
    this.exerciseId,
    this.exercise,
    this.categoryShellIds,
    this.autoOpen = false,
    this.onQuickAdd,
    required this.setExercise,
  }) : super(key: key);

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  Future<Exercise>? selectedExercise;
  late Future<List<Exercise>> allExercises;
  late List<int> categoryShellFilters = [];

  List<Exercise> temp = [];

  @override
  void initState() {
    super.initState();
    categoryShellFilters = widget.categoryShellIds ?? [];

    // exercise pre-selected
    if (widget.exerciseId != null) {
      allExercises = Future<List<Exercise>>.value([]);
      selectedExercise = ExercisesHelper.getExercise(id: widget.exerciseId!, includeUserDetails: true);
    } else {
      allExercises = ExercisesHelper.getAllExercisesExcludingCategories(categoryShellFilters);
    }
  }

  void onFilterSelect(BuildContext context, int shellId, bool selected) {
    Navigator.pop(context);
    setState(() {
      if (selected) {
        categoryShellFilters.add(shellId);
      } else {
        categoryShellFilters.remove(shellId);
      }

      allExercises = ExercisesHelper.getAllExercisesExcludingCategories(categoryShellFilters);
    });
  }

  Widget getFilterButton() => Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            getSectionTitle(context, 'Exercise Filters'),
                            const Divider(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: SingleChildScrollView(
                                child: getFilterChips(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              );
            },
            child: const Text('Filters'),
          ),
        ),
      ]);

  Widget getFilterChips() {
    return Center(
      child: Wrap(
        spacing: 5,
        runSpacing: 0,
        children: [
          ...ExerciseType.values
              .map((e) => e.index == ExerciseType.values.length - 1 ||
                      e.index == ExerciseType.weight.index // get rid of other and weight
                  ? const SizedBox.shrink()
                  : FilterChip(
                      label: Text(e.displayName),
                      selected: categoryShellFilters.contains(e.categoryShell.id),
                      onSelected: (bool selected) => onFilterSelect(context, e.categoryShell.id, selected),
                    ))
              .toList(),
          ...MuscleGroup.values
              .map((e) => e.index == MuscleGroup.values.length - 1 // get rid of other
                  ? const SizedBox.shrink()
                  : FilterChip(
                      label: Text(e.displayName),
                      selected: categoryShellFilters.contains(e.categoryShell.id),
                      onSelected: (bool selected) => onFilterSelect(context, e.categoryShell.id, selected),
                    ))
              .toList(),
          ...ExerciseSplit.values
              .map((e) => e.index == ExerciseSplit.values.length - 1 // get rid of other
                  ? const SizedBox.shrink()
                  : FilterChip(
                      label: Text(e.displayName),
                      selected: categoryShellFilters.contains(e.categoryShell.id),
                      onSelected: (bool selected) => onFilterSelect(context, e.categoryShell.id, selected),
                    ))
              .toList(),
        ],
      ),
    );
  }

  void showExercisePicker(
    List<Exercise> allExercises,
    Exercise? selectedExercise,
  ) {
    allExercises.sort((a, b) => a.muscleGroup.index.compareTo(b.muscleGroup.index));

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  getSectionTitle(context, 'Select Exercise'),
                  const Divider(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .7,
                    child: getPickerContent(allExercises, selectedExercise),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    );
  }

  Widget getPickerContent(
    List<Exercise> allExercises,
    Exercise? selectedExercise,
  ) {
    final Map<int, List<Exercise>> groupedExercises = groupBy<Exercise, int>(allExercises, (e) => e.muscleGroup.index);
    final List<Widget> sections = [];
    final addQuickAddButton = widget.onQuickAdd != null;

    groupedExercises.forEach((key, value) => sections.add(
          StickyHeader(
            header: Container(
              color: Theme.of(context).canvasColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Text(
                  value[0].exerciseType == ExerciseType.cardio
                      ? value[0].exerciseType.displayName
                      : value[0].muscleGroup.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ]),
            ),
            content: Column(
              children: value
                  .map(
                    (e) => Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.setExercise(e);
                          },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: selectedExercise != null && e.id == selectedExercise.id
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      e.name,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  getPropDisplay(context, e.equipment.displayName),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (addQuickAddButton)
                        getPrimaryButton(
                          actionButton: ActionButton(
                            icon: Icons.add_rounded,
                            onTap: () => widget.onQuickAdd!(e),
                          ),
                          padding: 0,
                        ),
                    ]),
                  )
                  .toList(),
            ),
          ),
        ));

    return Column(
      children: [
        // getFilterButton(),
        // const Padding(padding: EdgeInsets.all(5)),
        Expanded(child: SingleChildScrollView(child: Column(children: sections))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exercise>>(
        future: allExercises,
        builder: (context, allExercisesSnapshot) {
          if (!allExercisesSnapshot.hasData) {
            return const SizedBox.shrink();
          }

          var allExercises = allExercisesSnapshot.data!;
          var zeroExercises = allExercises.isEmpty;

          if (!zeroExercises) allExercises.sort((a, b) => a.equipment.index.compareTo(b.equipment.index));

          return FutureBuilder<Exercise>(
            future: selectedExercise,
            builder: ((context, snapshot) {
              final exercise = widget.exercise ?? snapshot.data;

              // first build of pre-selected exercise
              if (widget.exerciseId != null && widget.exercise == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.setExercise(exercise);
                });
              } else if (widget.autoOpen && exercise == null && temp != allExercises) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showExercisePicker(allExercises, exercise);
                });
              }

              // hacky fix for stupid problem (setState triggers build or addPostFrameCallback -> showExercisePicker twice)
              temp = allExercises;

              return Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: zeroExercises
                          ? null
                          : () => showExercisePicker(
                                allExercises,
                                exercise,
                              ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text(
                                      exercise == null ? '' : 'Exercise',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.shadow,
                                      ),
                                    ),
                                  ]),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        exercise == null ? 'Select Exercise' : exercise.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: exercise == null ? Theme.of(context).colorScheme.shadow : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.arrow_drop_down_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }
}
