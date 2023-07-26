import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/shared/workout_category_helper.dart';

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
  List<WorkoutCategoryShell> workoutCategories = WorkoutCategoryHelper.getCategoryShells();
  late List<int> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = widget.selectedWorkoutCategoryIds;
  }

  @override
  Widget build(BuildContext context) {
    onSubmit() async {
      Navigator.pop(context);

      try {
        await WorkoutsHelper.setWorkoutCategories(
          widget.workoutId,
          selectedIds,
        );
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add Category to workout')),
        );
      }

      widget.reloadState();
    }

    void onCategoryTap(int categoryId) async {
      setState(() {
        selectedIds.contains(categoryId) ? selectedIds.remove(categoryId) : selectedIds.add(categoryId);
      });

      await onSubmit();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: workoutCategories
                  .map(
                    (wc) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: GestureDetector(
                        onTap: () => onCategoryTap(wc.id),
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              border: Border.all(
                                width: 2,
                                color: selectedIds.contains(wc.id)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                            child: Text(wc.displayName),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
