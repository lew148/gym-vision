import 'package:flutter/material.dart';
import 'package:gymvision/exercises/category_view.dart';
import 'package:gymvision/db/helpers/categories_helper.dart';
import 'package:gymvision/db/classes/category.dart';

import '../shared/forms/add_category_form.dart';
import '../shared/ui_helper.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  Future<List<Category>> _categories = CategoriesHelper().getCategories();
  reloadState() => setState(() {
        _categories = CategoriesHelper().getCategories();
      });

  Widget getCategoryWidget(Category category) => Padding(
        padding: const EdgeInsets.all(5),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryView(
                categoryId: category.id!,
                categoryName: category.name,
              ),
            ),
          ).then((value) => reloadState()),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.emoji ?? '❔',
                    style: const TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  const Divider(),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget getCategories(List<Category> categories) {
    categories.sort(((a, b) => a.name.compareTo(b.name)));
    return Expanded(
      child: SingleChildScrollView(
        child: Wrap(children: categories.map((c) => getCategoryWidget(c)).toList()),
      ),
    );
  }

  void openAddCategoryForm() => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddCategoryForm(reloadState: reloadState),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      child: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          return Column(children: [
            getSectionTitleWithActions(
              context,
              'Categories',
              [ActionButton(icon: Icons.add_rounded, onTap: openAddCategoryForm)],
            ),
            const Divider(),
            getCategories(snapshot.data!),
          ]);
        },
      ),
    );
  }
}
