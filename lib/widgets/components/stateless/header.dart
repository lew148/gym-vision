import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String? title;
  final Widget? widget;
  final List<Widget>? actions;

  const Header({
    super.key,
    this.title,
    this.widget,
    this.actions,
  }) : assert(
          (title != null || widget != null) || (title == null || widget == null),
          'You must provide EITHER title OR widget to a Header',
        );

  @override
  Widget build(BuildContext context) {
    final Widget header = widget ??
        Text(
          title!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 15,
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        header,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (actions != null) ...actions!,
          ],
        ),
      ],
    );
  }
}
