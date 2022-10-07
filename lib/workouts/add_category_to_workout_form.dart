import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/category.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:search_choices/search_choices.dart';

import '../db/helpers/categories_helper.dart';

class AddCategoryToWorkoutForm extends StatefulWidget {
  final int workoutId;
  final List<int>? existingCategoryIds;
  final void Function() reloadState;

  const AddCategoryToWorkoutForm({
    Key? key,
    required this.workoutId,
    required this.existingCategoryIds,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddCategoryToWorkoutForm> createState() =>
      _AddCategoryToWorkoutFormState();
}

class _AddCategoryToWorkoutFormState extends State<AddCategoryToWorkoutForm> {
  late Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    categories = CategoriesHelper()
        .getAllCategoriesExcludingIds(widget.existingCategoryIds!);
  }

  final formKey = GlobalKey<FormState>();
  List<Category> categoriesRef = [];
  List<int> selectedItems = [];
  List<DropdownMenuItem> items = [];

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        final List<int> categoryIdsToAdd =
            selectedItems.map((si) => categoriesRef[si].id!).toList();

        await WorkoutsHelper.addCategoriesToWorkout(
            widget.workoutId, categoryIdsToAdd);
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add categories to workout: $ex')),
        );
      }

      widget.reloadState();
    }
  }

  @override
  Widget build(BuildContext context) {
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

              categoriesRef = snapshot.data!;
              items = snapshot.data!
                  .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Text(c.getDisplayName()),
                      ))
                  .toList();

              return Form(
                key: formKey,
                child: Column(
                  children: [
                    SearchChoices.multiple(
                      autofocus: true,
                      items: items,
                      selectedItems: selectedItems,
                      hint: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Select Categories"),
                      ),
                      searchHint: '',
                      onChanged: (value) {
                        setState(() {
                          selectedItems = value;
                        });
                      },
                      closeButton: (selectedItems) {
                        return (selectedItems.isNotEmpty
                            ? "Select ${selectedItems.length == 1 ? '"${items[selectedItems.first].value}"' : '(${selectedItems.length})'}"
                            : "Cancel");
                      },
                      doneButton: '',
                      isExpanded: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            onPressed: onSubmit,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
