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

  Widget getCategoryWidget(int id, String name) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryView(
                categoryId: id,
                categoryName: name,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: Colors.grey[600]!,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey[100],
            ),
            width: 200,
            padding: const EdgeInsets.all(20),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );

  List<Widget> getCategoriesRows(List<Category> categories) {
    List<Widget> rows = [];

    for (var i = 0; i < categories.length; i += 2) {
      var categoriesForRow = categories.sublist(
          i, i + 2 > categories.length ? categories.length : i + 2);

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categoriesForRow
            .map<Widget>((c) => getCategoryWidget(c.id!, c.name))
            .toList(),
      ));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
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
