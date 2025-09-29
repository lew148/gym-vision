import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double? height;
  final bool shadow;

  const CustomDivider({
    super.key,
    this.height,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 0.25, height: height, color: Theme.of(context).colorScheme.shadow);
  }
}
