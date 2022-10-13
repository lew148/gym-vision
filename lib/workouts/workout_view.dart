import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/workout_exercise.dart';
import 'package:gymvision/exercises/category_view.dart';
import 'package:gymvision/exercises/exercise_view.dart';
import 'package:gymvision/workouts/add_exercise_to_workout_form.dart';

import '../db/classes/workout.dart';
import '../db/classes/workout_category.dart';
import '../db/helpers/workouts_helper.dart';
import 'add_category_to_workout_form.dart';

class WorkoutView extends StatefulWidget {
  final int workoutId;
  final String? workoutDateString;
  const WorkoutView(
      {super.key, required this.workoutId, this.workoutDateString});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  reloadState() => setState(() {});

  void onAddExerciseClick(List<int> existingExerciseIds) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddExerciseToWorkoutForm(
                workoutId: widget.workoutId,
                existingExerciseIds: existingExerciseIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  void onAddCategoryClick(List<int> existingCategoryIds) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddCategoryToWorkoutForm(
                workoutId: widget.workoutId,
                existingCategoryIds: existingCategoryIds,
                reloadState: reloadState,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  Widget getSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.shadow,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  void showRemoveCategoryFromWorkoutConfirm(int workoutCategoryId) {
    Widget cancelButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text(
        "Yes",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        Navigator.pop(context);

        try {
          await WorkoutsHelper.removeCategoryFromWorkout(workoutCategoryId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to remove Category from workout: ${ex.toString()}')),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Category from Workout?"),
      content: const Text(
          "Are you sure you would like to remove this Category from this workout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  void showRemoveExerciseFromWorkoutConfirm(int workoutExerciseId) {
    Widget cancelButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text(
        "Yes",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        Navigator.pop(context);

        try {
          await WorkoutsHelper.removeExerciseFromWorkout(workoutExerciseId);
        } catch (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to remove Exercise from workout: ${ex.toString()}')),
          );
        }

        reloadState();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Remove Exercise from Workout?"),
      content: const Text(
          "Are you sure you would like to remove this Exercise from this workout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  getWorkoutCategoriesWidget(List<WorkoutCategory>? workoutCategories) {
    if (workoutCategories == null || workoutCategories.isEmpty) {
      return const Center(
        child: Text('No Category has been set yet...'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: workoutCategories
          .map((wc) => Padding(
                padding: const EdgeInsets.only(left: 15),
                child: InkWell(
                  onLongPress: () =>
                      showRemoveCategoryFromWorkoutConfirm(wc.id!),
                  onTap: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => CategoryView(
                            categoryId: wc.categoryId,
                            categoryName: wc.category!.name,
                          ),
                        ),
                      )
                      .then((value) => setState(() {})),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.75,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      wc.category!.getDisplayName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  List<Widget> getWorkoutExercisesWidget(
      List<WorkoutExercise>? workoutExercises) {
    if (workoutExercises == null || workoutExercises.isEmpty) {
      return const [
        Center(
          child: Text('No exercises here...'),
        ),
      ];
    }

    return workoutExercises
        .map(
          (we) => Card(
            child: InkWell(
              onLongPress: () => showRemoveExerciseFromWorkoutConfirm(we.id!),
              onTap: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => ExerciseView(
                        exerciseId: we.exerciseId,
                        exerciseName: we.exercise!.name,
                      ),
                    ),
                  )
                  .then((value) => setState(() {})),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      we.exercise!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${we.sets} sets'),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Future<Workout> workout = WorkoutsHelper().getWorkout(
      workoutId: widget.workoutId,
      includeCategories: true,
      includeExercises: true,
    );
    List<int> existingCategoryIds = [];
    List<int> existingExerciseIds = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutDateString ?? 'New Workout'),
      ),
      body: FutureBuilder<Workout>(
        future: workout,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          if (snapshot.data!.workoutCategories != null &&
              snapshot.data!.workoutCategories!.isNotEmpty) {
            existingCategoryIds = snapshot.data!.workoutCategories!
                .map((we) => we.categoryId)
                .toList();
          } else {
            existingCategoryIds = [];
          }

          if (snapshot.data!.workoutExercises != null &&
              snapshot.data!.workoutExercises!.isNotEmpty) {
            existingExerciseIds = snapshot.data!.workoutExercises!
                .map((we) => we.exerciseId)
                .toList();
          } else {
            existingExerciseIds = [];
          }

          return Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSectionTitle('Categories'),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              onAddCategoryClick(existingCategoryIds),
                          child: const Icon(
                            Icons.add,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                padding: const EdgeInsets.all(10),
                child: getWorkoutCategoriesWidget(
                  snapshot.data!.workoutCategories,
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSectionTitle('Exercises'),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              onAddExerciseClick(existingExerciseIds),
                          child: const Icon(
                            Icons.add,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: getWorkoutExercisesWidget(
                        snapshot.data!.workoutExercises,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
