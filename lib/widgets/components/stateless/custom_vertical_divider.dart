import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  final double? thickness;
  final Color? color;

  const CustomVerticalDivider({
    super.key,
    this.thickness,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(thickness: thickness ?? 0.25, color: color ?? Theme.of(context).colorScheme.shadow);
  }
}
