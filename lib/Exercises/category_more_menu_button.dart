import 'package:flutter/material.dart';
import 'package:gymvision/shared/forms/basic/single_text_field_form.dart';

import '../db/classes/category.dart';
import '../db/helpers/categories_helper.dart';

class CategoryMoreMenuButton extends StatefulWidget {
  final int categoryId;
  final Function() reloadState;
  final Function()? onDelete;

  const CategoryMoreMenuButton({
    super.key,
    required this.categoryId,
    required this.reloadState,
    this.onDelete,
  });

  @override
  State<CategoryMoreMenuButton> createState() => _CategoryMoreMenuButtonState();
}

class _CategoryMoreMenuButtonState extends State<CategoryMoreMenuButton> {
  late Future<Category> category;

  @override
  void initState() {
    super.initState();
    category = CategoriesHelper.getCategory(widget.categoryId);
  }

  void showMoreMenu(Category category) {
    void onEditNameSubmit(bool formValid, String newValue) async {
      Navigator.pop(context);

      try {
        if (category.name == newValue) {
          return;
        }

        category.name = newValue;

        await CategoriesHelper.updateCategory(category);
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to edit Category')),
        );
      }

      Navigator.pop(context);
    }

    void onEditNameTap() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleTextFieldForm(
                title: "Edit Category Name",
                label: "Name",
                initialValue: category.name,
                onSubmit: onEditNameSubmit,
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      );
    }

    void showDeleteCategoryConfirm() {
      Widget cancelButton = TextButton(
        child: const Text("No"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      Widget continueButton = TextButton(
        child: const Text(
          "Yes",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          Navigator.pop(context);

          try {
            await CategoriesHelper.deleteCategory(category.id!);
          } catch (ex) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete Category: ${ex.toString()}'),
              ),
            );
          }

          if (widget.onDelete == null) {
            widget.reloadState();
          } else {
            widget.onDelete!();
            widget.reloadState();
          }
        },
      );

      AlertDialog alert = AlertDialog(
        title: const Text("Delete Category?"),
        content: const Text("Are you sure you would like to delete this Category?"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      showDialog(
        context: context,
        builder: (context) => alert,
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onEditNameTap();
                },
                child: Row(
                  children: const [
                    Icon(Icons.edit_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Edit Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showDeleteCategoryConfirm();
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_rounded),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category>(
        future: category,
        builder: ((context, snapshot) {
          return IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => snapshot.hasData ? showMoreMenu(snapshot.data!) : null,
          );
        }));
  }
}
