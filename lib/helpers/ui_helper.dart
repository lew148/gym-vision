import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class UiHelper {
  static Widget getSectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.all(10),
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

  static Widget getPrimaryButton(ActionButton actionButton) => TextButton(
        onPressed: actionButton.onTap,
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
      );

  static Widget getOutlinedPrimaryButton(ActionButton actionButton) => OutlinedButton(
        onPressed: actionButton.onTap,
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
      );

  static Widget getElevatedPrimaryButton(BuildContext context, ActionButton actionButton) => ElevatedButton(
        onPressed: actionButton.onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (actionButton.icon != null)
              Icon(
                actionButton.icon,
                size: 25,
                color: Colors.black,
              ),
            if (actionButton.icon != null && actionButton.text != null)
              const Padding(padding: EdgeInsets.only(left: 5)),
            if (actionButton.text != null)
              Text(
                actionButton.text!,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );

  static Widget getSectionTitleWithAction(BuildContext context, String title, ActionButton actionButton) =>
      getSectionTitleWithActions(context, title, [actionButton]);

  static Widget getSectionTitleWithActions(BuildContext context, String title, List<ActionButton> actionButtons) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getSectionTitle(context, title),
          Row(children: actionButtons.map((ab) => getPrimaryButton(ab)).toList()),
        ],
      );

  static Widget getPropDisplay(BuildContext context, String text) => Container(
        margin: const EdgeInsets.all(2.5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.shadow),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text, textAlign: TextAlign.center),
      );

  static Widget getTappablePropDisplay(BuildContext context, String text, Function() onTap) => Container(
      margin: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.shadow),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ));

  static void showDeleteConfirm(
    BuildContext context,
    Function onDelete,
    Function reloadState,
    String objectName,
  ) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove $objectName?"),
        content: Text("Are you sure you would like to remove this $objectName?"),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              try {
                await onDelete();
              } catch (ex) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Failed to remove $objectName: ${ex.toString()}')));
              }

              reloadState();
            },
          ),
        ],
      ),
    );
  }
}
