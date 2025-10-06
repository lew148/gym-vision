import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/models/default_exercises_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/pages/exercise/exercise_view.dart';
import 'package:gymvision/widgets/forms/category_picker.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class Exercises extends StatefulWidget {
  final List<Category>? filterCategories;
  final List<String>? excludedExerciseIdentifiers;
  final Function(String identifier)? onAddTap;

  const Exercises({
    super.key,
    this.filterCategories,
    this.excludedExerciseIdentifiers,
    this.onAddTap,
  });

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  late List<Category> filterCategories;
  late List<Exercise> filteredExercises;
  late TextEditingController searchTextController;
  ExerciseType selectedType = ExerciseType.strength;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    filterCategories = widget.filterCategories ?? [];
    filteredExercises = getFilteredExercises();

    if (filterCategories.length == 1 && filterCategories[0] == Category.cardio) {
      selectedType = ExerciseType.cardio;
      filterCategories = [];
      filteredExercises = getCardioExercises();
    }
  }

  List<Exercise> getFilteredExercises() => DefaultExercisesModel.getExercises(
        categories: filterCategories,
        excludedExerciseIds: widget.excludedExerciseIdentifiers,
        includeCardio: false,
      );

  List<Exercise> getCardioExercises() => DefaultExercisesModel.getExercises(
        categories: [Category.cardio],
        excludedExerciseIds: widget.excludedExerciseIdentifiers,
      );

  setSearchValue(String? string) => setState(() {
        selectedType = ExerciseType.strength;

        if (string == null) {
          filteredExercises = getFilteredExercises();
          return;
        }

        filteredExercises =
            getFilteredExercises().where((e) => e.name.contains(RegExp(string, caseSensitive: false))).toList();

        if (filteredExercises.isEmpty) {
          filteredExercises = getFilteredExercises()
              .where((e) => e.primaryMuscleGroup.displayName.contains(RegExp(string, caseSensitive: false)))
              .toList();
        }

        if (filteredExercises.isEmpty) {
          filteredExercises = getFilteredExercises()
              .where((e) => e.equipment.displayName.contains(RegExp(string, caseSensitive: false)))
              .toList();
        }

        if (filteredExercises.isEmpty) {
          filteredExercises =
              getCardioExercises().where((e) => e.name.contains(RegExp(string, caseSensitive: false))).toList();
          selectedType = ExerciseType.cardio;
        }
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
                    Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(children: [
                      if (exercise.equipment != Equipment.other)
                        Text(
                          exercise.equipment.displayName,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      // if (exercise.primaryMuscleGroup != MuscleGroup.other && exercise.equipment != Equipment.other)
                      //   const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5), child: Text('-')),
                      // if (exercise.primaryMuscleGroup != MuscleGroup.other)
                      //   Text(exercise.primaryMuscleGroup.displayNamePlain,
                      //       style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    ]),
                  ],
                ),
              ]),
            ),
          ),
        ),
        if (widget.onAddTap != null)
          Button(
            icon: Icons.add_rounded,
            onTap: () => widget.onAddTap!(exercise.identifier),
          ),
      ]);

  void onCategoriesChange(List<Category> newCategories) {
    setState(() {
      filterCategories = newCategories;
      filteredExercises = getFilteredExercises();
      selectedType = ExerciseType.strength;
    });
  }

  void showCategories() => showCloseableBottomSheet(
        context,
        CateogryPicker(
          selectedCategories: filterCategories,
          onChange: onCategoriesChange,
          includeMiscCategories: false,
        ),
      );

  Widget getExercisesScrollView() {
    final List<Widget> sections = [];
    final Map<int, List<Exercise>> groups =
        groupBy<Exercise, int>(filteredExercises, (e) => e.primaryMuscleGroup.index);

    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsetsGeometry.all(10),
        child: Column(children: [
          Text('No results for: ${searchTextController.text}'),
          Text('Create the Extercise: -> Coming Soon!',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ]),
      );
    }

    final sortedKeys = groups.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      final group = groups[sortedKeys[i]];
      if (group == null || group.isEmpty) continue;

      group.sort((a, b) {
        final aString = '${a.equipment.index}${a.name}';
        final bString = '${b.equipment.index}${b.name}';
        return aString.compareTo(bString);
      });

      sections.add(
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
          child: Column(
            children: [
              Row(children: [
                Text(
                  group.first.type == ExerciseType.strength
                      ? group.first.primaryMuscleGroup.displayName
                      : group.first.type.displayName,
                ),
              ]),
              const Padding(padding: EdgeInsetsGeometry.all(5)),
              ...group.map((e) => getExerciseWidget(e)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
        child: Column(children: [
      ...sections,
      const ScrollBottomPadding(),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CupertinoSlidingSegmentedControl<ExerciseType>(
        groupValue: selectedType,
        onValueChanged: (ExerciseType? value) {
          if (value != null) {
            setState(() {
              selectedType = value;
              filteredExercises = selectedType == ExerciseType.cardio ? getCardioExercises() : getFilteredExercises();
            });
          }
        },
        children: const <ExerciseType, Widget>{
          ExerciseType.strength: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Exercises'),
          ),
          ExerciseType.cardio: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Cardio'),
          ),
          // todo: add stretches
        },
      ),
      const Padding(padding: EdgeInsetsGeometry.all(5)),
      Row(children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: searchTextController,
            placeholder: 'Search for exercise...',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onChanged: (s) => setSearchValue(s),
            suffixIcon: const Icon(Icons.clear_rounded),
            onSuffixTap: () {
              closeKeyboard();
              setSearchValue(null);
              searchTextController.clear();
            },
          ),
        ),
      ]),
      if (selectedType != ExerciseType.cardio)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              icon: Icons.category_rounded,
              onTap: showCategories,
              style: ButtonCustomStyle(padding: const EdgeInsets.all(10)),
            ),
          ],
        ),
      Expanded(child: getExercisesScrollView()),
    ]);
  }
}
