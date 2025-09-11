import 'package:flutter/material.dart';
import 'package:gymvision/services/apis/todoist_service.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/common/forms/fields/custom_form_fields.dart';

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
        CustomFormFields.stringField(
          controller: titleController,
          label: 'Title',
          autofocus: true,
          canBeBlank: false,
          maxLength: 250,
        ),
        CustomFormFields.textArea(
          controller: descriptionController,
          label: 'Description',
          canBeBlank: true,
        ),
        CustomFormFields.stringField(
          controller: nameController,
          label: 'Your Name',
          canBeBlank: true,
          maxLength: 15,
        ),
        CustomFormFields.checkboxWithLabel(
          context,
          'Is a bug?',
          isBug,
          (v) => setState(() {
            isBug = !isBug;
          }),
        ),
        Padding(
          padding: const EdgeInsetsGeometry.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [CommonUI.getTextButton(ButtonDetails(text: 'Report', onTap: onSubmit))],
          ),
        ),
      ]),
    );
  }
}
