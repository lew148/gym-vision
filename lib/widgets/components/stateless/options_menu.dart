import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';

class OptionsMenu extends StatelessWidget {
  final List<Button> buttons;
  final String? title;
  final IconData? icon;

  const OptionsMenu({
    super.key,
    required this.buttons,
    this.title,
    this.icon,
  });

  static void showOptionsMenu(BuildContext context, {required List<Button> buttons, String? title}) {
    HapticFeedback.heavyImpact();
    final List<Widget> items = title == null
        ? []
        : [
            Header(title: title),
            const CustomDivider(),
          ];

    for (int i = 0; i < buttons.length; i++) {
      if (i != 0) items.add(const CustomDivider(shadow: true));
      items.add(buttons[i]);
    }

    showCloseableBottomSheet(context, Column(children: items));
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      onTap: () => showOptionsMenu(context, buttons: buttons, title: title),
      icon: icon ?? Icons.more_vert_rounded,
    );
  }
}
