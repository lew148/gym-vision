import 'package:flutter/material.dart';
import 'package:gymvision/exercises/category_view.dart';
import 'package:gymvision/db/helpers/categories_helper.dart';
import 'package:gymvision/db/classes/category.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  final Future<List<Category>> _categories = CategoriesHelper().getCategories();

  Widget getCategoryWidget(Category category) => Container(
        margin: const EdgeInsets.only(bottom: 20),
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

  List<Widget> getCategoriesRows(List<Category> categories) {
    List<Widget> rows = [];

    categories.sort(((a, b) => a.name.compareTo(b.name)));

    for (var i = 0; i < categories.length; i += 2) {
      var categoriesForRow = categories.sublist(
          i, i + 2 > categories.length ? categories.length : i + 2);

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

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          return Column(
            children: getCategoriesRows(snapshot.data!),
          );
        },
      ),
    );
  }
}
