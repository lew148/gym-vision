import 'package:flutter/material.dart';
import 'package:gymvision/models/db_models/workout_category_model.dart';
import 'package:gymvision/pages/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class AddCategoryToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final List<Category> existingCategories;
  final void Function() reloadState;

  const AddCategoryToWorkoutForm({
    super.key,
    required this.workoutId,
    required this.existingCategories,
    required this.reloadState,
  });

  @override
  State<AddCategoryToWorkoutForm> createState() => _AddCategoryToWorkoutFormState();
}

class _AddCategoryToWorkoutFormState extends State<AddCategoryToWorkoutForm> {
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.existingCategories;
  }

  onSubmit() async {
    Navigator.pop(context);

    try {
      await WorkoutCategoryModel.setWorkoutCategories(widget.workoutId, selectedCategories);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Category to workout')));
    }

    widget.reloadState();
  }

  void onCategoryTap(Category category) async {
    setState(() {
      selectedCategories.contains(category) ? selectedCategories.remove(category) : selectedCategories.add(category);
    });

    await onSubmit();
  }

  Widget getCategoryDisplay(Category category) => GestureDetector(
        onTap: () => onCategoryTap(category),
        child: CommonUi.getCard(
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
              border: Border.all(
                width: 2,
                color:
                    selectedCategories.contains(category) ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(category.displayName),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CommonUi.getSectionTitle(context, 'Add Categories'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Column(children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.splitCategories.map((c) => getCategoryDisplay(c)).toList(),
                ),
                const Divider(thickness: 0.25),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.split2Categories.map((c) => getCategoryDisplay(c)).toList(),
                ),
                const Divider(thickness: 0.25),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.muscleGroupCategories.map((c) => getCategoryDisplay(c)).toList(),
                ),
                const Divider(thickness: 0.25),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.miscCategories.map((c) => getCategoryDisplay(c)).toList(),
                ),
              ])
            ]),
          ),
        ],
      ),
    );
  }
}
