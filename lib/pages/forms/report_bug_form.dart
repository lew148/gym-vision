import 'package:flutter/material.dart';
import 'package:gymvision/external_apis/todoist_service.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/fields/custom_form_fields.dart';

class ReportBugForm extends StatefulWidget {
  const ReportBugForm({super.key});

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
    final success = await TodoistService.createTask(
      titleController.text,
      descriptionController.text,
      nameController.text,
      isBug,
    );
    if (!mounted) return;
    final message = success ? 'Report sent!' : 'Failed to send report';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        CommonUI.getSectionTitleWithCloseButton(context, 'Bug/Feature Report'),
        CommonUI.getDefaultDivider(),
        CustomFormFields.stringField(
          controller: titleController,
          label: 'Title',
          autofocus: true,
          canBeBlank: false,
          maxLength: 500,
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
        ),
        CustomFormFields.checkbox(
          context,
          'Is Bug',
          isBug,
          (v) => setState(() {
            isBug = !isBug;
          }),
        ),
        CommonUI.getElevatedPrimaryButton(context, ButtonDetails(text: 'Report', onTap: onSubmit))
      ]),
    );
  }
}
