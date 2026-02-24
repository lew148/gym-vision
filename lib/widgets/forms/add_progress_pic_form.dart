import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/forms/pickers/date_time_picker.dart';
import 'package:gymvision/widgets/pages/image_picker_page.dart';

class AddProgressPicForm extends StatefulWidget {
  const AddProgressPicForm({super.key});

  @override
  State<AddProgressPicForm> createState() => _AddProgressPicFormState();
}

class _AddProgressPicFormState extends State<AddProgressPicForm> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();

  void _onDateTimeSelected(DateTime dt) {
    setState(() {
      selectedDate = dt;
    });

    // Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePickerPage(
          multiple: false,
          onImagesSelected: (images) {
            // Handle the selected images and the associated date here
            print('Selected date: $selectedDate');
            print('Selected images: $images');
          },
        ),
      ),
    );
  }

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
            DateTimePicker(
              onChange: (dt) => _onDateTimeSelected,
              mode: CupertinoDatePickerMode.dateAndTime,
              initialValue: selectedDate,
            ),
          ],
        ),
      ),
    );
  }
}
