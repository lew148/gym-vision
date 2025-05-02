import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class ExercisePicker extends StatefulWidget {
  final String? exerciseIdentifier;
  final Exercise? exercise;
  final List<Category>? setCategories;
  final List<String>? excludedExercises;
  final bool autoOpen;
  final Function(Exercise exercise)? onQuickAdd;
  final Function setExerciseForParent;

  const ExercisePicker({
    super.key,
    this.exerciseIdentifier,
    this.exercise,
    this.setCategories,
    this.excludedExercises,
    this.autoOpen = false,
    this.onQuickAdd,
    required this.setExerciseForParent,
  });

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  late List<Exercise> filteredExercises;
  List<Category> filterCategories = [];
  Future<Exercise?>? selectedExercise;

  List<Exercise> temp = [];

  @override
  void initState() {
    super.initState();
    filterCategories.addAll(widget.setCategories ?? []);

    // exercise pre-selected
    if (widget.exerciseIdentifier != null) {
      filteredExercises = [];
      selectedExercise = DefaultExercisesModel.getExerciseWithDetails(identifier: widget.exerciseIdentifier!);
    } else {
      filteredExercises = DefaultExercisesModel.getExercises(
        categories: filterCategories,
        excludedExerciseIds: widget.excludedExercises,
      );
    }
  }

  void onFilterSelect(BuildContext context, Category category, bool selected) {
    Navigator.pop(context);
    setState(() {
      if (selected) {
        filterCategories.add(category);
      } else {
        filterCategories.remove(category);
      }

      filteredExercises = DefaultExercisesModel.getExercises(
          categories: filterCategories, excludedExerciseIds: widget.excludedExercises);
    });
  }

  Widget getFilterButton() => Row(children: [
        Expanded(
          child: CommonUi.getElevatedPrimaryButton(
            context,
            ButtonDetails(
              onTap: () {
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BackButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        filteredExercises = DefaultExercisesModel.getExercises(
                                            categories: filterCategories,
                                            excludedExerciseIds: widget.excludedExercises);
                                      });
                                    },
                                  ),
                                  CommonUi.getSectionTitle(context, 'Exercise Filters'),
                                ],
                              ),
                              const Divider(thickness: 0.25),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: SingleChildScrollView(child: getFilterChips()),
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
              text: 'Filters',
            ),
          ),
        ),
      ]);

  Widget getFilterChips() {
    return Wrap(
      spacing: 5,
      children: [
        ...SplitHelper.splitCategories.map(
          (e) => FilterChip(
            backgroundColor: Theme.of(context).cardColor,
            selectedColor: Colors.grey[600],
            label: Text(e.displayName),
            selected: filterCategories.contains(e),
            onSelected: (bool selected) => onFilterSelect(context, e, selected),
          ),
        ),
        const Divider(thickness: 0.25),
        ...SplitHelper.muscleGroupCategories.map(
          (e) => FilterChip(
            backgroundColor: Theme.of(context).cardColor,
            selectedColor: Colors.grey[600],
            label: Text(e.displayName),
            selected: filterCategories.contains(e),
            onSelected: (bool selected) => onFilterSelect(context, e, selected),
          ),
        ),
        // const Divider(thickness: 0.25),
        // ...ExerciseType.values.map((e) => e.index == ExerciseType.values.length - 1 ||
        //         e.index == ExerciseType.stretch.index ||
        //         e.index == ExerciseType.weight.index // get rid of other, stretch and weight
        //     ? const SizedBox.shrink()
        //     : FilterChip(
        //         backgroundColor: Theme.of(context).cardColor,
        //         selectedColor: Colors.grey[600],
        //         label: Text(e.displayName),
        //         selected: filterCategories.contains(e.categoryShell.id),
        //         onSelected: (bool selected) => onFilterSelect(context, e.categoryShell.id, selected),
        //       )),
      ],
    );
  }

  void showExercisePicker(List<Exercise> allExercises, Exercise? selectedExercise) {
    allExercises.sort((a, b) => a.name.compareTo(b.name));

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonUi.getSectionTitle(context, 'Select Exercise'),
                      CloseButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  const Divider(thickness: 0.25),
                  getFilterButton(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .75,
                    child: filteredExercises.isEmpty && selectedExercise == null
                        ? Center(
                            child: Text(
                              'No exercises found',
                              style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                            ),
                          )
                        : getPickerContent(allExercises, selectedExercise),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    );
  }

  Widget getPickerContent(List<Exercise> allExercises, Exercise? selectedExercise) {
    final Map<int, List<Exercise>> exercisesGroupedByMuscleGroup =
        groupBy<Exercise, int>(allExercises, (e) => e.primaryMuscleGroup.index);
    final List<Widget> sections = [];
    final addQuickAddButton = widget.onQuickAdd != null;

    exercisesGroupedByMuscleGroup.forEach((key, value) => sections.add(
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Text(
                  value[0].type == ExerciseType.strength
                      ? value[0].primaryMuscleGroup.displayName
                      : value[0].type.displayName,
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
                    (e) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.setExerciseForParent(e);
                      },
                      child: CommonUi.getCard(
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                            border: Border.all(
                              width: 2,
                              color: selectedExercise != null && e.identifier == selectedExercise.identifier
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
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
                                    // UiHelper.getPropDisplay(context, e.equipment.displayName),
                                  ],
                                ),
                              ),
                              if (addQuickAddButton)
                                CommonUi.getPrimaryButton(
                                  ButtonDetails(
                                    icon: Icons.add_rounded,
                                    onTap: () => widget.onQuickAdd!(e),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ));

    return Column(children: [Expanded(child: SingleChildScrollView(child: Column(children: sections)))]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise?>(
      future: selectedExercise,
      builder: ((context, snapshot) {
        final exercise = widget.exercise ?? snapshot.data;
        final disabled = filteredExercises.isEmpty && exercise != null;

        // first build of pre-selected exercise
        if (widget.exerciseIdentifier != null && widget.exercise == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.setExerciseForParent(exercise);
          });
        } else if (widget.autoOpen && exercise == null && temp != filteredExercises) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showExercisePicker(filteredExercises, exercise);
          });
        }

        // hacky fix for stupid problem (setState triggers build or addPostFrameCallback -> showExercisePicker twice)
        temp = filteredExercises;

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => disabled ? null : showExercisePicker(filteredExercises, exercise),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
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
                            const Padding(padding: EdgeInsets.only(bottom: 5)),
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
                      if (!disabled)
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
  }
}
