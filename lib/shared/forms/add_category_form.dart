import 'package:flutter/material.dart';
import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';
class AddCategoryForm extends StatefulWidget {
  final void Function() reloadState;

  const AddCategoryForm({
    Key? key,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emojiController = TextEditingController();

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        // await CategoriesHelper.addCategory(Category(
        //   name: nameController.text,
        //   emoji: emojiController.text,
        // ));
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add Category')),
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
            'Add Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormFields.stringField(
                  controller: nameController,
                  label: 'Name',
                  autofocus: true,
                ),
                CustomFormFields.stringField(
                  controller: emojiController,
                  label: 'Emoji',
                  canBeBlank: true,
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
          )
        ],
      ),
    );
  }
}
