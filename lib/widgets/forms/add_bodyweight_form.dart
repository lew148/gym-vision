import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/common/common_ui.dart';
import 'fields/custom_form_fields.dart';

class AddBodyWeightForm extends StatefulWidget {
  const AddBodyWeightForm({super.key});

  @override
  State<AddBodyWeightForm> createState() => _AddBodyWeightFormState();
}

class _AddBodyWeightFormState extends State<AddBodyWeightForm> {
  final formKey = GlobalKey<FormState>();
  TextEditingController weightController = TextEditingController();

  void onSubmit() async {
    try {
      if (!formKey.currentState!.validate()) return;

      var now = DateTime.now();
      var weight = double.tryParse(weightController.text);
      if (weight != null) {
        await BodyweightModel.insert(Bodyweight(date: now, weight: weight, units: 'kg'));
      }
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to add Bodyweight');
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: CustomFormFields.doubleField(
                controller: weightController,
                label: 'BW',
                unit: 'kg',
                autofocus: true,
                hideNone: true,
              ),
            ),
            const Padding(padding: EdgeInsetsGeometry.all(20)),
            CommonUI.getDoneButton(onSubmit, isAdd: true),
          ]),
        ],
      ),
    );
  }
}
