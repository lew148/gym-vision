import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: 0.25),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
