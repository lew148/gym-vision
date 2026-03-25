import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  final Color? customColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderWidth;
  final bool primaryborder;
  final double? customElevation;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.customColor,
    this.padding,
    this.borderWidth,
    this.margin,
    this.primaryborder = false,
    this.customElevation,
  });

  factory CustomCard.display({
    required Widget child,
    Function()? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) =>
      CustomCard(
        primaryborder: true,
        padding: padding,
        margin: margin,
        borderWidth: 2,
        onTap: onTap,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      elevation: customElevation ?? 4,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
      color: customColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: primaryborder ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.shadow,
          width: borderWidth ?? 0.25,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
