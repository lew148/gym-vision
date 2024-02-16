import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/helpers/bodyweight_helper.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'fields/custom_form_fields.dart';

class AddWeightForm extends StatefulWidget {
  final Function reloadState;

  const AddWeightForm({
    Key? key,
    required this.reloadState,
  }) : super(key: key);

  @override
  State<AddWeightForm> createState() => _AddWeightFormState();
}

class _AddWeightFormState extends State<AddWeightForm> {
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add workout')));
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
              getSectionTitle(context, 'Add Weight'),
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
                    ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text('Add'),
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
