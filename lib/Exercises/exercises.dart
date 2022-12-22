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
  final Future<List<Category>> _categories = CategoriesHelper().getCategories();
  reloadState() => setState(() {});

  Widget getCategoryWidget(Category category) => Padding(
        padding: const EdgeInsets.only(bottom: 2.5, top: 2.5),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryView(
                categoryId: category.id!,
                categoryName: category.name,
              ),
            ),
          ),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
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
    List<Widget> rows = [];
    categories.sort(((a, b) => a.name.compareTo(b.name)));

    for (var i = 0; i < categories.length; i += 2) {
      var categoriesForRow = categories.sublist(i, i + 2 > categories.length ? categories.length : i + 2);

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 5,
            child: getCategoryWidget(categoriesForRow[0]),
          ),
          Expanded(
            flex: 5,
            child: getCategoryWidget(categoriesForRow[1]),
          ),
        ],
      ));
    }

    return Expanded(child: SingleChildScrollView(child: Column(children: rows)));
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
