import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';
import 'package:gymvision/widgets/forms/fields/datetime_field.dart';

class AddBodyWeightForm extends StatefulWidget {
  final DateTime? date;

  const AddBodyWeightForm({
    super.key,
    this.date,
  });

  @override
  State<AddBodyWeightForm> createState() => _AddBodyWeightFormState();
}

class _AddBodyWeightFormState extends State<AddBodyWeightForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController weightController = TextEditingController();
  DateTime? date;

  @override
  void initState() {
    super.initState();
    date = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
        child: Column(
          children: [
            Column(children: [
              DateTimeField(
                label: 'Date & Time',
                mode: CupertinoDatePickerMode.dateAndTime,
                dateTime: date,
                onChange: (v) => setState(() => date = v),
              ),
              CustomFormField.double(
                controller: weightController,
                label: 'BW',
                unit: 'kg',
                autofocus: true,
                prefixIcon: Icons.monitor_weight_rounded,
                canBeBlank: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button.submit(
                    text: 'Add',
                    onTap: () async {
                      try {
                        if (!formKey.currentState!.validate() || date == null) return;

                        var weight = double.tryParse(weightController.text);
                        if (weight != null) {
                          await BodyweightModel.insert(Bodyweight(date: date!, weight: weight, units: 'kg'));
                        }
                      } catch (ex) {
                        if (!context.mounted) return;
                        AppHelper.showSnackBar(context, 'Failed to add Bodyweight');
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
