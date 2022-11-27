import 'package:flutter/material.dart';

class CustomFormFields {
  static stringField({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    bool canBeBlank = false,
  }) =>
      TextFormField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (!canBeBlank && (value == null || value == '')) {
            return '$label cannot be blank';
          }
        },
      );

  static weightField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, suffix: const Text('kg')),
        validator: (value) => value == null || double.tryParse(value) == null
            ? 'Please enter a valid weight'
            : null,
      );

  static intField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );
}
