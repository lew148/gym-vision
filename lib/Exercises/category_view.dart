import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/exercise.dart';
import 'package:gymvision/exercises/exercise_more_menu_button.dart';

import '../db/helpers/exercises_helper.dart';
import '../shared/forms/add_exercise_form.dart';
import '../shared/ui_helper.dart';
import 'exercise_view.dart';

class CategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryView({super.key, required this.categoryId, required this.categoryName});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  reloadState() => setState(() {});

  Widget getExerciseWidget(Exercise exercise) => Row(
        children: [
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => ExerciseView(
                          exerciseId: exercise.id!,
                          exerciseName: exercise.name,
                        ),
                      ),
                    )
                    .then((value) => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          if (exercise.hasWeight())
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: 15,
                                    color: Theme.of(context).colorScheme.shadow,
                                  ),
                                  const Padding(padding: EdgeInsets.all(5)),
                                  Text(
                                    exercise.getNumberedWeightString(showNone: false) ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.shadow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Icon(
                                Icons.repeat_rounded,
                                size: 15,
                                color: Theme.of(context).colorScheme.shadow,
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(
                                '${exercise.reps} rep${exercise.singleRep() ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.shadow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ExerciseMoreMenuButton(
                        exercise: exercise,
                        reloadState: reloadState,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void openAddExerciseForm() => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddExerciseForm(
                categoryId: widget.categoryId,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  @override
  Widget build(BuildContext context) {
    final Future<List<Exercise>> exercises = ExercisesHelper.getExercisesForCategory(widget.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<Exercise>>(
        future: exercises,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Exercises here :(',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: Column(children: [
              getSectionTitleWithActions(
                context,
                'Exercises',
                [ActionButton(icon: Icons.add_rounded, onTap: openAddExerciseForm)],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Column(children: snapshot.data!.map((c) => getExerciseWidget(c)).toList()),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
