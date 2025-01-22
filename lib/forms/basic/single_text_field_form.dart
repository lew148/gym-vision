import 'package:flutter/material.dart';
import 'package:gymvision/helpers/ui_helper.dart';

import '../fields/custom_form_fields.dart';

class SingleTextFieldForm extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;

  final void Function(bool, String) onSubmit;

  const SingleTextFieldForm({
    super.key,
    required this.title,
    required this.label,
    required this.initialValue,
    required this.onSubmit,
  });

  @override
  State<SingleTextFieldForm> createState() => _SingleTextFieldFormState();
}

class _SingleTextFieldFormState extends State<SingleTextFieldForm> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fieldController = TextEditingController(text: widget.initialValue);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormFields.stringField(
                  controller: fieldController,
                  label: widget.label,
                  canBeBlank: false,
                  autofocus: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: UiHelper.getElevatedPrimaryButton(
                        context,
                        ActionButton(
                          onTap: () => widget.onSubmit(formKey.currentState!.validate(), fieldController.text),
                          text: 'Save',
                        ),
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
