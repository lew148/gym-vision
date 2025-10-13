import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.borderWidth,
    this.margin,
  });

  factory CustomCard.field({required Widget child, Function()? onTap}) => CustomCard(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 2.5),
        borderWidth: 1.5,
        onTap: onTap,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: borderWidth ?? 0.25),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
