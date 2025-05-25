import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/pages/exercises/exercise_view.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  List<Exercise> filteredExercises = DefaultExercisesModel.getExercises();
  late TextEditingController searchTextController;
  String searchValue = '';

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    sortExercises();
  }

  setSearchValue(String? string) => setState(() {
        if (string == null) {
          filteredExercises = DefaultExercisesModel.getExercises();
          sortExercises();
          return;
        }

        filteredExercises = DefaultExercisesModel.getExercises()
            .where((e) => e.name.contains(RegExp(string, caseSensitive: false)))
            .toList();

        if (filteredExercises.isEmpty) {
          filteredExercises = DefaultExercisesModel.getExercises()
              .where((e) => e.primaryMuscleGroup.displayName.contains(RegExp(string, caseSensitive: false)))
              .toList();
        }

        if (filteredExercises.isEmpty) {
          filteredExercises = DefaultExercisesModel.getExercises()
              .where((e) => e.equipment.displayName.contains(RegExp(string, caseSensitive: false)))
              .toList();
        }

        sortExercises();
      });

  void sortExercises() => filteredExercises.sort((a, b) {
        final aString = '${a.type.index}${a.name}';
        final bString = '${b.type.index}${b.name}';
        return aString.compareTo(bString);
      });

  Widget getExerciseWidget(Exercise exercise) => Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ExerciseView(identifier: exercise.identifier))),
              child: Row(children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage("assets/images/logo.png"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.getName()),
                    if (exercise.primaryMuscleGroup != MuscleGroup.other)
                      Text(exercise.primaryMuscleGroup.displayNamePlain,
                          style: TextStyle(color: Theme.of(context).colorScheme.shadow)),
                  ],
                ),
              ]),
            ),
          ),
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: searchTextController,
            placeholder: 'Search',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onChanged: (s) => setSearchValue(s),
          ),
        ),
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            setSearchValue(null);
          },
          child: const Text('Cancel'),
        ),
      ]),
      const Padding(padding: EdgeInsets.all(2)),
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: filteredExercises.map((e) => getExerciseWidget(e)).toList()),
        ),
      ),
    ]);
  }
}
