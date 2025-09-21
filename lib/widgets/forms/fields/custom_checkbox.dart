import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final Future<bool> Function(bool)? onChange;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChange,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void onChange(bool? newValue) async {
    if (newValue == null) return;

    final success = await widget.onChange!(newValue);
    if (!success) return;

    setState(() {
      value = newValue;
    });
  }

  @override
  void didUpdateWidget(covariant CustomCheckbox old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) setState(() => value = widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Transform.scale(
        scale: 1.1,
        child: Checkbox(
          checkColor: Theme.of(context).colorScheme.surface,
          activeColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: 2),
          shape: const CircleBorder(),
          value: value,
          onChanged: widget.onChange == null ? null : onChange,
        ),
      ),
    );
  }
}
