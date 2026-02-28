import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/image_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/forms/fields/datetime_field.dart';
import 'package:gymvision/widgets/forms/fields/image_select_field.dart';

class AddProgressPicForm extends StatefulWidget {
  const AddProgressPicForm({super.key});

  @override
  State<AddProgressPicForm> createState() => _AddProgressPicFormState();
}

class _AddProgressPicFormState extends State<AddProgressPicForm> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
        child: Column(
          children: [
            Header(title: 'Add Progress Pic'),
            CustomDivider(shadow: true),
            ImageSelectField(
              label: 'Progress Picture',
              images: selectedImage != null ? [selectedImage!] : null,
              onChange: (images) => setState(() {
                selectedImage = images?.first;
              }),
            ),
            DateTimeField(
              label: 'Date & Time',
              onChange: (v) => setState(() {
                selectedDate = v ?? DateTime.now();
              }),
              dateTime: selectedDate,
              mode: CupertinoDatePickerMode.dateAndTime,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button.submit(
                  text: 'Add',
                  onTap: () async {
                    try {
                      if (!formKey.currentState!.validate() || selectedImage == null) return;
                      var success = await ImageHelper.addProgressPic(selectedImage!, dateTime: selectedDate);
                      if (!success) throw 'Failed to add Progress Pic';
                    } catch (ex) {
                      if (!context.mounted) return;
                      AppHelper.showSnackBar(context, 'Failed to add Progress Pic');
                    }

                    if (!context.mounted) return;
                    AppHelper.showSnackBar(context, 'Progress Pic added successfully!');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
