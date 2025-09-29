import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'fields/custom_form_fields.dart';

class AddBodyWeightForm extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final TextEditingController weightController = TextEditingController();

  AddBodyWeightForm({super.key});

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
            Button.done(
              onTap: () async {
                try {
                  if (!formKey.currentState!.validate()) return;

                  var now = DateTime.now();
                  var weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    await BodyweightModel.insert(Bodyweight(date: now, weight: weight, units: 'kg'));
                  }
                } catch (ex) {
                  if (!context.mounted) return;
                  showSnackBar(context, 'Failed to add Bodyweight');
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              isAdd: true,
            ),
          ]),
        ],
      ),
    );
  }
}
