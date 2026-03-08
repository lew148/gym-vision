import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/enums.dart';

class ButtonCustomStyle {
  final bool mutedIcon;
  final bool mutedText;

  Color? iconColor;
  final double? iconSize;

  Color? textColor;
  final double? textSize;

  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment? alignment;

  ButtonCustomStyle({
    this.mutedText = false,
    this.mutedIcon = false,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.textSize,
    this.padding,
    this.alignment,
  });

  void resolveMutes(Color muteColor) {
    if (mutedIcon) iconColor = muteColor;
    if (mutedText) textColor = muteColor;
  }

  factory ButtonCustomStyle.muted() => ButtonCustomStyle(mutedText: true, mutedIcon: true);
  factory ButtonCustomStyle.mutedTextOnly() => ButtonCustomStyle(mutedIcon: false, mutedText: true);
  factory ButtonCustomStyle.redIconMutedText() => ButtonCustomStyle(iconColor: Colors.red, mutedText: true);
  factory ButtonCustomStyle.redIconRedText() => ButtonCustomStyle(iconColor: Colors.red, textColor: Colors.red);
  factory ButtonCustomStyle.noPadding() => ButtonCustomStyle(padding: EdgeInsets.zero);
}

class Button extends StatelessWidget {
  final Function()? onTap;
  final Function()? onLongTap;
  final IconData? icon;
  final String? text;
  final ButtonType type;
  final ButtonCustomStyle? style;
  final bool disabled;

  const Button({
    super.key,
    this.type = ButtonType.text,
    this.onTap,
    this.onLongTap,
    this.icon,
    this.text,
    this.style,
    this.disabled = false,
  }) : assert(text != null || icon != null, 'Must provide text and/or icon to Button');

  factory Button.centered({
    String? text,
    IconData? icon,
    Function()? onTap,
    Function()? onLongTap,
    bool disabled = false,
  }) =>
      Button(
        style: ButtonCustomStyle(alignment: MainAxisAlignment.center),
        onTap: onTap,
        onLongTap: onLongTap,
        icon: icon,
        text: text,
        disabled: disabled,
      );

  factory Button.elevated({
    String? text,
    IconData? icon,
    Function()? onTap,
    Function()? onLongTap,
    bool disabled = false,
  }) =>
      Button(
        type: ButtonType.elevated,
        onTap: onTap,
        onLongTap: onLongTap,
        icon: icon,
        text: text,
        disabled: disabled,
      );

  factory Button.outlined({
    String? text,
    IconData? icon,
    ButtonCustomStyle? style,
    Function()? onTap,
    Function()? onLongTap,
    bool disabled = false,
  }) =>
      Button(
        type: ButtonType.outlined,
        onTap: onTap,
        onLongTap: onLongTap,
        icon: icon,
        text: text,
        style: style,
        disabled: disabled,
      );

  factory Button.delete({required Function() onTap, String? text}) => Button(
        onTap: onTap,
        icon: Icons.delete_rounded,
        text: text,
        style: ButtonCustomStyle.redIconMutedText(),
      );

  factory Button.add({required Function() onTap, String? text}) => Button(
        text: text,
        icon: Icons.add_rounded,
        onTap: onTap,
        style: ButtonCustomStyle.mutedTextOnly(),
      );

  factory Button.submit({required Function() onTap, String? text}) => Button(
        onTap: onTap,
        text: text ?? 'Done',
        type: ButtonType.elevated,
      );

  factory Button.cancel({required Function() onTap}) => Button(
        text: 'Cancel',
        onTap: onTap,
        style: ButtonCustomStyle.redIconRedText(),
      );

  factory Button.clear({required Function() onTap, bool useIcon = false}) => Button(
        icon: useIcon ? Icons.clear_rounded : null,
        text: useIcon ? null : 'Clear',
        onTap: onTap,
      );

  factory Button.calendar({required Function() onTap}) => Button(icon: Icons.calendar_today_rounded, onTap: onTap);
  factory Button.check({required Function() onTap}) => Button(icon: Icons.check_rounded, onTap: onTap);

  factory Button.edit({required Function() onTap, String? text}) => Button(
        text: text,
        icon: Icons.edit_rounded,
        onTap: onTap,
        style: ButtonCustomStyle.mutedTextOnly(),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final shadow = colorScheme.shadow;
    final onPrimary = colorScheme.onPrimary;

    style?.resolveMutes(shadow);

    final padding = style?.padding ?? const EdgeInsets.all(10);
    final minimumSize = Size.zero;
    final tapTargetSize = MaterialTapTargetSize.shrinkWrap;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

    final iconSize = style?.iconSize ?? 25;
    final iconColor = style?.iconColor ?? (type == ButtonType.elevated ? onPrimary : primary);

    final textWeight = FontWeight.w700;
    final textSize = style?.textSize ?? 16;
    final textColor = style?.textColor ?? (type == ButtonType.elevated ? onPrimary : primary);

    Widget getTextAndIcon() => Row(
          mainAxisAlignment:
              style?.alignment ?? (type == ButtonType.text ? MainAxisAlignment.start : MainAxisAlignment.center),
          children: [
            if (icon != null) Icon(icon, size: iconSize, color: iconColor),
            if (icon != null && text != null) const Padding(padding: EdgeInsets.all(5)),
            if (text != null)
              Text(
                text!,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: textWeight,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        );

    Widget getTextButton() => TextButton(
          style: TextButton.styleFrom(
            padding: padding,
            minimumSize: minimumSize,
            tapTargetSize: tapTargetSize,
            shape: shape,
          ),
          onPressed: disabled ? null : onTap,
          onLongPress: disabled ? null : onLongTap,
          child: getTextAndIcon(),
        );

    Widget getOutlinedButton() => Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding,
              minimumSize: minimumSize,
              tapTargetSize: tapTargetSize,
              shape: shape,
              backgroundColor: primary.withValues(alpha: 0.05),
              foregroundColor: primary,
              side: BorderSide(color: primary, width: 2.5),
            ),
            onPressed: disabled ? null : onTap,
            onLongPress: disabled ? null : onLongTap,
            child: getTextAndIcon(),
          ),
        );

    Widget getElevatedButton() => Container(
          margin: const EdgeInsetsGeometry.symmetric(vertical: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding,
              minimumSize: minimumSize,
              tapTargetSize: tapTargetSize,
              shape: shape,
              backgroundColor: primary.withValues(alpha: 0.95),
              elevation: 4,
              shadowColor: shadow.withValues(alpha: 0.5),
            ),
            onPressed: disabled ? null : onTap,
            onLongPress: disabled ? null : onLongTap,
            child: getTextAndIcon(),
          ),
        );

    return switch (type) {
      ButtonType.text => getTextButton(),
      ButtonType.outlined => getOutlinedButton(),
      ButtonType.elevated => getElevatedButton()
    };
  }
}
