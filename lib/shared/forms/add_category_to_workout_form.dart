import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';

import '../../db/helpers/categories_helper.dart';

class AddCategoryToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final List<int> selectedCategoryIds;
  final void Function() reloadState;

  const AddCategoryToWorkoutForm({
    Key? key,
    required this.workoutId,
    required this.selectedCategoryIds,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddCategoryToWorkoutForm> createState() =>
      _AddCategoryToWorkoutFormState();
}

class _AddCategoryToWorkoutFormState extends State<AddCategoryToWorkoutForm> {
  late Future<List<Category>> categories;
  late List<int> selectedIds;

  @override
  void initState() {
    super.initState();
    categories = CategoriesHelper().getCategories();
    selectedIds = widget.selectedCategoryIds;
  }

  void onCategoryTap(int categoryId) {
    setState(() {
      selectedIds.contains(categoryId)
          ? selectedIds.remove(categoryId)
          : selectedIds.add(categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getCategorySelect(List<Category> categories) => Wrap(
          alignment: WrapAlignment.center,
          children: categories
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: () => onCategoryTap(c.id!),
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(
                            width: 2,
                            color: selectedIds.contains(c.id)
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                        child: Text(c.getDisplayName()),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );

    void onSubmit() async {
      Navigator.pop(context);

      try {
        await WorkoutsHelper.setWorkoutCategories(
          widget.workoutId,
          selectedIds,
        );
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add categories to workout: $ex')),
        );
      }

      widget.reloadState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Add Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          FutureBuilder<List<Category>>(
            future: categories,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }

              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No Categories here :('),
                );
              }

              return Column(
                children: [
                  const Padding(padding: EdgeInsets.all(15)),
                  getCategorySelect(snapshot.data!),
                  const Padding(padding: EdgeInsets.all(15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
