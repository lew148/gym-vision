import 'package:flutter/material.dart';
import 'package:gymvision/services/apis/todoist_service.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/forms/fields/checkbox_with_label.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';

class ReportBugForm extends StatefulWidget {
  final Function(bool)? onReportSent;

  const ReportBugForm({
    super.key,
    this.onReportSent,
  });

  @override
  State<ReportBugForm> createState() => _ReportBugFormState();
}

class _ReportBugFormState extends State<ReportBugForm> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  bool isBug = false;

  void onSubmit() async {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(context);
    var success = await TodoistService.createTask(
      titleController.text,
      descriptionController.text,
      nameController.text,
      isBug,
    );

    if (widget.onReportSent != null) widget.onReportSent!(success);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        CustomFormField.string(
          controller: titleController,
          label: 'Title',
          autofocus: true,
          canBeBlank: false,
          maxLength: 250,
        ),
        CustomFormField.textArea(
          controller: descriptionController,
          label: 'Description',
        ),
        CustomFormField.string(
          controller: nameController,
          label: 'Your Name',
          maxLength: 15,
        ),
        CheckbockWithLabel(
          label: 'Is a bug',
          value: isBug,
          onChange: (v) => setState(() {
            isBug = !isBug;
          }),
        ),
        Padding(
          padding: const EdgeInsetsGeometry.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Button(text: 'Report', onTap: onSubmit)],
          ),
        ),
      ]),
    );
  }
}
