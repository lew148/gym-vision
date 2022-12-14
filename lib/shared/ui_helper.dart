import 'package:flutter/material.dart';

Widget getSectionTitle(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.shadow,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

Widget getPrimaryButton({required ActionButton actionButton, double? padding}) => Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: OutlinedButton(
        onPressed: actionButton.onTap,
        child: Padding(
          padding: EdgeInsets.all(padding ?? 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (actionButton.icon != null)
                Icon(
                  actionButton.icon,
                  size: 25,
                ),
              if (actionButton.icon != null && actionButton.text != null)
                const Padding(padding: EdgeInsets.only(left: 5)),
              if (actionButton.text != null) Text(actionButton.text!),
            ],
          ),
        ),
      ),
    );

class ActionButton {
  Function() onTap;
  IconData? icon;
  String? text;

  ActionButton({
    required this.onTap,
    this.icon,
    this.text,
  });
}

Widget getSectionTitleWithAction(BuildContext context, String title, ActionButton actionButton) =>
    getSectionTitleWithActions(context, title, [actionButton]);

Widget getSectionTitleWithActions(BuildContext context, String title, List<ActionButton> actionButtons) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        getSectionTitle(context, title),
        Row(
          children: actionButtons.map((ab) => getPrimaryButton(actionButton: ab)).toList(),
        ),
      ],
    );
