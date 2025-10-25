import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> values;
  final String? intialValue;
  final Function(String?)? onChange;
  final IconData? prefixIcon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.values,
    this.intialValue,
    this.onChange,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    OutlineInputBorder getBorder() => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.shadow, width: 1.5),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: intialValue,
        items: values
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, style: TextStyle(fontWeight: FontWeight.normal)),
                ))
            .toList(),
        onChanged: onChange,
        borderRadius: BorderRadius.circular(10),
        decoration: InputDecoration(
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: colorScheme.secondary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
          contentPadding: const EdgeInsets.all(10),
          enabledBorder: getBorder(),
          focusedBorder: getBorder(),
        ),
      ),
    );
  }
}
