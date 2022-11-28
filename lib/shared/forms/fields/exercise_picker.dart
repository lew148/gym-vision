import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';

import '../../../db/classes/exercise.dart';

class ExercisePicker extends StatefulWidget {
  final int? exerciseId;
  final Exercise? exercise;
  final List<int>? excludeIds;
  final List<int>? categoryIds;
  final bool disabled;
  final Function setExercise;

  const ExercisePicker({
    Key? key,
    this.exerciseId,
    this.exercise,
    this.excludeIds,
    this.categoryIds,
    this.disabled = false,
    required this.setExercise,
  }) : super(key: key);

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  Future<Exercise>? selectedExercise;
  late Future<List<Exercise>> allExercises;

  @override
  void initState() {
    super.initState();
    allExercises = ExercisesHelper.getAllExercisesExcludingIds(
      widget.excludeIds,
      widget.categoryIds,
    );

    if (widget.exerciseId != null && widget.exercise == null) {
      selectedExercise = ExercisesHelper.getExercise(widget.exerciseId!);
    }
  }

  void showExercisePicker(
    List<Exercise> allExercises,
    Exercise? selectedExercise,
  ) =>
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
                    const Text(
                      'Select Exercise',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 800,
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              getPickerContent(allExercises, selectedExercise),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  List<Widget> getPickerContent(
    List<Exercise> allExercises,
    Exercise? selectedExercise,
  ) {
    allExercises.sort(((a, b) => a.category!.name.compareTo(b.category!.name)));

    final Map<int, List<Exercise>> groupedExercises =
        groupBy(allExercises, (e) => e.categoryId);

    List<Widget> sections = [];

    groupedExercises.forEach((key, value) {
      sections.add(Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          Row(children: [
            Text(
              value.first.category!.getDisplayName(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ]),
          const Divider(),
          ...value
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(top: 5),
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
                            color: selectedExercise != null &&
                                    e.id == selectedExercise.id
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (e.hasWeight())
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.fitness_center,
                                            size: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .shadow,
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.all(5)),
                                          Text(
                                            e.getNumberedWeightString(
                                                showNone: false) ?? '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .shadow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        size: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                      ),
                                      const Padding(padding: EdgeInsets.all(5)),
                                      Text(
                                        '${e.reps} rep${e.singleRep() ? '' : 's'}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ));
    });

    return sections;
  }

  List<Widget> getPickerIcons() => [
        const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(Icons.arrow_drop_down),
        ),
        IconButton(
          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
          onPressed: () => widget.setExercise(null),
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exercise>>(
        future: allExercises,
        builder: (context, allExercisesSnapshot) {
          if (!allExercisesSnapshot.hasData ||
              allExercisesSnapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          return FutureBuilder<Exercise>(
            future: selectedExercise,
            builder: ((context, snapshot) {
              final exercise = widget.exercise ?? snapshot.data;

              // first build of pre-selected exercise
              if (widget.exerciseId != null && widget.exercise == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.setExercise(exercise);
                });
              }

              return Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.disabled
                          ? null
                          : () => showExercisePicker(
                                allExercisesSnapshot.data!,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                      ),
                                    ),
                                  ]),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        exercise == null
                                            ? 'Select Exercise'
                                            : exercise.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: exercise == null
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .shadow
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!widget.disabled) ...getPickerIcons(),
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
