import 'package:flutter/material.dart';
import 'package:gymvision/widgets/forms/fields/custom_checkbox.dart';

class CustomCheckboxWithLabel extends StatefulWidget {
  final String label;
  final bool value;
  final Function(bool)? onChange;

  const CustomCheckboxWithLabel({
    super.key,
    required this.label,
    required this.value,
    this.onChange,
  });

  @override
  State<StatefulWidget> createState() => _CustomCheckboxWithLabelState();
}

class _CustomCheckboxWithLabelState extends State<CustomCheckboxWithLabel> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final newValue = !value;
        setState(() {
          value = newValue;
        });

        if (widget.onChange != null) widget.onChange!(newValue);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(children: [
          CustomCheckbox(value: value, onChange: widget.onChange),
          const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
          Text(widget.label, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ]),
      ),
    );
  }
}
