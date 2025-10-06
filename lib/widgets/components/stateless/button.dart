import 'package:flutter/material.dart';

class ButtonCustomStyle {
  bool primaryText;
  Color? textColor;
  Color? iconColor;
  double? iconSize;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;

  ButtonCustomStyle({
    this.primaryText = true,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.padding,
  });

  factory ButtonCustomStyle.primaryIconOnly() => ButtonCustomStyle(primaryText: false);
  factory ButtonCustomStyle.redIconOnly() => ButtonCustomStyle(iconColor: Colors.red, primaryText: false);
  factory ButtonCustomStyle.redIconAndText() => ButtonCustomStyle(iconColor: Colors.red, textColor: Colors.red);
  factory ButtonCustomStyle.noPadding() => ButtonCustomStyle(padding: EdgeInsets.zero);
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
        style: ButtonCustomStyle.redIconOnly(),
      );

  factory Button.done({required Function() onTap, bool isAdd = false, String? customTitle}) => Button(
        onTap: onTap,
        text: customTitle ?? (isAdd ? 'Add' : 'Done'),
      );

  factory Button.x({required Function() onTap}) => Button(icon: Icons.close_rounded, onTap: onTap);
  factory Button.calendar({required Function() onTap}) => Button(icon: Icons.calendar_today_rounded, onTap: onTap);
  factory Button.clear({required Function() onTap}) => Button(text: 'Clear', onTap: onTap);

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
                  if (icon != null) Icon(icon, size: 25, color: style?.iconColor),
                  if (icon != null && text != null) const Padding(padding: EdgeInsets.all(5)),
                  if (text != null)
                    Text(
                      text!,
                      style: TextStyle(
                        color: style == null ? null : style!.textColor ?? (style!.primaryText ? null : onSurface),
                      ),
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
                if (icon != null) Icon(icon, size: style?.iconSize ?? 25, color: style?.iconColor),
                if (icon != null && text != null) const Padding(padding: EdgeInsets.all(5)),
                if (text != null)
                  Text(
                    text!,
                    style: TextStyle(
                      color: style == null ? null : style!.textColor ?? (style!.primaryText ? null : onSurface),
                    ),
                  ),
              ],
            ),
          );
  }
}
