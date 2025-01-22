import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/helpers/bodyweight_helper.dart';
import 'package:gymvision/helpers/ui_helper.dart';
import 'fields/custom_form_fields.dart';

class AddBodyWeightForm extends StatefulWidget {
  final Function reloadState;

  const AddBodyWeightForm({
    super.key,
    required this.reloadState,
  });

  @override
  State<AddBodyWeightForm> createState() => _AddBodyWeightFormState();
}

class _AddBodyWeightFormState extends State<AddBodyWeightForm> {
  final formKey = GlobalKey<FormState>();
  TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void onSubmit() async {
      try {
        var now = DateTime.now();
        var weight = double.tryParse(weightController.text);
        if (weight != null) {
          await BodyweightHelper.insertBodyweight(Bodyweight(date: now, weight: weight, units: 'kg'));
        }
        if (!mounted) return;
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Bodyweight')));
      }

      Navigator.pop(context);
      widget.reloadState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: IntrinsicHeight(
          child: Column(
            children: [
              UiHelper.getSectionTitle(context, 'Add Weight'),
              const Divider(thickness: 0.25),
              CustomFormFields.doubleField(
                controller: weightController,
                label: 'Weight',
                isDouble: false,
                unit: 'kg',
                autofocus: true,
                hideNone: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UiHelper.getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: onSubmit,
                        text: 'Add',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
