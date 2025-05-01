import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/pages/common_ui.dart';
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
          await BodyweightModel.insertBodyweight(Bodyweight(date: now, weight: weight, units: 'kg'));
        }
      } catch (ex) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Bodyweight')));
      }

      if (!context.mounted) return;
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
              CommonUi.getSectionTitle(context, 'Add Weight'),
              const Divider(thickness: 0.25),
              CustomFormFields.doubleField(
                controller: weightController,
                label: 'Weight',
                unit: 'kg',
                autofocus: true,
                hideNone: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonUi.getElevatedPrimaryButton(
                      context,
                      ButtonDetails(
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
