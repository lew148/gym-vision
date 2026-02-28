import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';

class ImportDataForm extends StatefulWidget {
  const ImportDataForm({super.key});

  @override
  State<ImportDataForm> createState() => _ImportDataFormState();
}

class _ImportDataFormState extends State<ImportDataForm> {
  final formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();

  void onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    if ((await DialogHelper.showConfirm(
          context,
          title: 'Import Data?',
          content: 'Importing data could lose exercise and set orderings.',
        )) ==
        false) {
      return;
    }

    if (mounted) Navigator.pop(context);

    var success = false;

    try {
      success = await AppHelper.importData(inputController.text);
    } catch (e) {
      success = false;
    }

    if (mounted) {
      success
          ? ToastHelper.showSuccessToast(context, message: 'Data imported successfully!')
          : ToastHelper.showFailureToast(context, message: 'Failed to import data!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        CustomFormField.textArea(controller: inputController, label: 'Import String', maxLines: 20),
        Padding(
          padding: const EdgeInsetsGeometry.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Button(
                  icon: Icons.paste_rounded,
                  onTap: () async {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    setState(() {
                      inputController.text = clipboardData?.text ?? '';
                    });
                  },
                ),
                if (inputController.text.isNotEmpty)
                  Button.clear(
                    onTap: () {
                      setState(() {
                        inputController.text = '';
                      });
                    },
                  ),
              ]),
              Button(text: 'Import', onTap: onSubmit),
            ],
          ),
        ),
      ]),
    );
  }
}
