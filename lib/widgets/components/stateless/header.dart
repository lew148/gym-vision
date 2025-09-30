import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String? title;
  final Widget? widget;
  final List<Widget>? actions;
  final bool large;

  const Header({
    super.key,
    this.title,
    this.widget,
    this.actions,
    this.large = false,
  }) : assert(
          (title != null || widget != null) || (title == null || widget == null),
          'You must provide EITHER title OR widget to a Header',
        );

  factory Header.large(String title, {List<Widget>? actions}) => Header(title: title, large: true, actions: actions);

  @override
  Widget build(BuildContext context) {
    final Widget header = widget ??
        Text(
          title!,
          style: large
              ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
              : TextStyle(
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
