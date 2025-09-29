import 'package:flutter/material.dart';

class ButtonCustomStyle {
  bool primaryText;
  bool primaryIcon;
  Color? textColor;
  Color? iconColor;
  double? iconSize;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;

  ButtonCustomStyle({
    this.primaryText = false,
    this.primaryIcon = false,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.padding,
  });

  factory ButtonCustomStyle.primaryIcon() => ButtonCustomStyle(primaryIcon: true, primaryText: false);
  factory ButtonCustomStyle.primaryIconAndText() => ButtonCustomStyle(primaryText: true, primaryIcon: true);
  factory ButtonCustomStyle.noPadding() => ButtonCustomStyle(padding: EdgeInsets.zero);
  factory ButtonCustomStyle.redIcon() => ButtonCustomStyle(iconColor: Colors.red, primaryText: false);
  factory ButtonCustomStyle.redIconAndText() => ButtonCustomStyle(iconColor: Colors.red, textColor: Colors.red);
}

class Button extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final ButtonCustomStyle? style;
  final Function()? onTap;
  final Function()? onLongTap;
  final bool disabled;
  final bool elevated;

  const Button({
    super.key,
    this.elevated = false,
    this.onTap,
    this.onLongTap,
    this.icon,
    this.text,
    this.style,
    this.disabled = false,
  }) : assert(text != null || icon != null, 'Must provide text and/or icon to Button');

  factory Button.delete({required Function() onTap, String? text}) => Button(
        onTap: onTap,
        icon: Icons.delete_rounded,
        text: text,
        style: ButtonCustomStyle(iconColor: Colors.red),
      );

  factory Button.done({required Function() onTap, bool isAdd = false, String? customTitle}) => Button(
        onTap: onTap,
        text: customTitle ?? (isAdd ? 'Add' : 'Done'),
      );

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return elevated
        ? Padding(
            padding: const EdgeInsetsGeometry.symmetric(vertical: 2.5),
            child: ElevatedButton(
              onPressed: disabled ? null : onTap,
              onLongPress: disabled ? null : onLongTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: style?.backgroundColor,
                padding: style?.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.padded,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                overlayColor: Colors.grey,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: 25,
                      color: style?.iconColor ?? (style?.primaryIcon ?? true ? null : onSurface),
                    ),
                  if (icon != null && text != null) const Padding(padding: EdgeInsets.all(5)),
                  if (text != null)
                    Text(
                      text!,
                      style: TextStyle(color: style?.textColor ?? (style?.primaryText ?? true ? null : onSurface)),
                    ),
                ],
              ),
            ),
          )
        : TextButton(
            style: TextButton.styleFrom(
              backgroundColor: style?.backgroundColor,
              padding: style?.padding ?? const EdgeInsets.all(10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              overlayColor: Colors.grey,
            ),
            onPressed: disabled ? null : onTap,
            onLongPress: disabled ? null : onLongTap,
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: style?.iconSize ?? 25,
                    color: style?.iconColor ?? (style?.primaryIcon ?? true ? null : onSurface),
                  ),
                if (icon != null && text != null) const Padding(padding: EdgeInsets.all(5)),
                if (text != null)
                  Text(
                    text!,
                    style: TextStyle(color: style?.textColor ?? (style?.primaryText ?? true ? null : onSurface)),
                  ),
              ],
            ),
          );
  }
}
