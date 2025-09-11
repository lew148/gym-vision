import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/common/forms/fields/custom_form_fields.dart';

class ImportWorkoutForm extends StatefulWidget {
  const ImportWorkoutForm({super.key});

  @override
  State<ImportWorkoutForm> createState() => _ImportWorkoutFormState();
}

class _ImportWorkoutFormState extends State<ImportWorkoutForm> {
  final formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();

  void onSubmit() async {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(context);
    var success = await WorkoutModel.importWorkout(inputController.text);
    if (mounted) showSnackBar(context, success ? 'Workout(s) imported success!' : 'Failed to import workout(s)');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        CustomFormFields.textArea(
          controller: inputController,
          label: 'Workout String',
        ),
        Padding(
          padding: const EdgeInsetsGeometry.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI.getTextButton(ButtonDetails(
                  text: 'Paste',
                  onTap: () async {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    setState(() {
                      inputController.text = clipboardData?.text ?? '';
                    });
                  })),
              CommonUI.getTextButton(ButtonDetails(text: 'Import', onTap: onSubmit)),
            ],
          ),
        ),
      ]),
    );
  }
}
