import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final void Function(bool)? onChange;
  final Future<bool> Function(bool)? onChangeAsync;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChange,
    this.onChangeAsync,
  }) : assert(
          (onChange != null || onChangeAsync != null) || (onChange == null || onChangeAsync == null),
          'Must provide EITHER onChange OR asyncOnChange to CustomCheckbox',
        );

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

  void onCheckChange(bool? newValue) async {
    if (newValue == null) return;

    if (widget.onChange != null) {
      widget.onChange!(newValue);
    } else if (widget.onChangeAsync != null) {
      final success = await widget.onChangeAsync!(newValue);
      if (!success) return;
    }

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
          onChanged: widget.onChange == null && widget.onChangeAsync == null ? null : onCheckChange,
        ),
      ),
    );
  }
}
