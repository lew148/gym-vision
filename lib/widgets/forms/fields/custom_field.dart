import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';

class CustomField extends StatelessWidget {
  final Widget child;
  final Function()? onTap;

  const CustomField({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.shadow,
          width: 1.5,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: child),
      ),
    );
  }
}
