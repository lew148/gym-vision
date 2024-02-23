import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/helpers/category_shell_helper.dart';
import 'package:gymvision/shared/ui_helper.dart';

class AddCategoryToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final List<int> selectedWorkoutCategoryIds;
  final void Function() reloadState;

  const AddCategoryToWorkoutForm({
    Key? key,
    required this.workoutId,
    required this.selectedWorkoutCategoryIds,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddCategoryToWorkoutForm> createState() => _AddCategoryToWorkoutFormState();
}

class _AddCategoryToWorkoutFormState extends State<AddCategoryToWorkoutForm> {
  Map<int, List<WorkoutCategoryShell>> workoutCategories = CategoryShellHelper.getCategoryShellsMap();
  late List<int> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = widget.selectedWorkoutCategoryIds;
  }

  onSubmit() async {
    Navigator.pop(context);

    try {
      await WorkoutsHelper.setWorkoutCategories(
        widget.workoutId,
        selectedIds,
      );
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Category to workout')));
    }

    widget.reloadState();
  }

  void onCategoryTap(int categoryId, int section) async {
    setState(() {
      selectedIds.contains(categoryId) ? selectedIds.remove(categoryId) : selectedIds.add(categoryId);
    });

    await onSubmit();
  }

  Widget getCategoryDisplay(int section, WorkoutCategoryShell wc) => GestureDetector(
        onTap: () => onCategoryTap(wc.id, section),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
              border: Border.all(
                width: 2,
                color: selectedIds.contains(wc.id) ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(wc.displayName),
          ),
        ),
      );

  List<Widget> getCategorySections(Map<int, List<WorkoutCategoryShell>> workoutCategories) {
    List<Widget> sections = [];

    workoutCategories.forEach((k, v) {
      sections.add(Column(children: [
        const Divider(thickness: 0.25),
        Wrap(
          alignment: WrapAlignment.center,
          children: v.map((c) => getCategoryDisplay(k, c)).toList(),
        ),
      ]));
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    var relevantWorkoutCategories = workoutCategories;

    var cardioIsFirstInList = selectedIds.isNotEmpty && selectedIds.first == 1;
    var selectedIdsIsOnlyCardio = selectedIds.length == 1 && selectedIds.contains(1);

    if (selectedIds.isNotEmpty && !selectedIdsIsOnlyCardio) {
      // keep index 2 (cardio) always
      relevantWorkoutCategories.removeWhere(
        (key, value) => key != 2 && key != CategoryShellHelper.getMapIndexOfShell(selectedIds[(cardioIsFirstInList ? 1 : 0)]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          getSectionTitle(context, 'Add Categories'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: getCategorySections(relevantWorkoutCategories)),
          ),
        ],
      ),
    );
  }
}
