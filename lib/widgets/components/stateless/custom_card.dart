import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  final Color? customColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderWidth;
  final bool isField;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.customColor,
    this.padding,
    this.borderWidth,
    this.margin,
    this.isField = false,
  });

  factory CustomCard.field({required Widget child, Function()? onTap}) => CustomCard(
        isField: true,
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
      color: isField ? Theme.of(context).colorScheme.surface : customColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
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
