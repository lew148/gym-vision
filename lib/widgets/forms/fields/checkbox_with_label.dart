import 'package:flutter/material.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';

class CheckbockWithLabel extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool)? onChange;

  const CheckbockWithLabel({
    super.key,
    required this.label,
    required this.value,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        CustomCheckbox(value: value, onChange: onChange),
        const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      ]),
    );
  }
}
