import 'package:flutter/material.dart';

class ButtonDetails {
  Function()? onTap;
  Function()? onLongTap;
  IconData? icon;
  String? text;

  ButtonDetails({
    this.onTap,
    this.onLongTap,
    this.icon,
    this.text,
  });
}

class CommonUI {
  static Widget getSectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
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

  static Widget getSectionTitleWithCloseButton(
    BuildContext context,
    String title, {
    bool popCaller = false,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getSectionTitle(context, title),
          CloseButton(
            onPressed: () {
              Navigator.pop(context);
              if (popCaller) Navigator.pop(context);
            },
          )
        ],
      );

  static Widget getSectionTitleWithAction(BuildContext context, String title, ButtonDetails actionButton) =>
      getSectionTitleWithActions(context, title, [actionButton]);

  static Widget getSectionTitleWithActions(BuildContext context, String title, List<ButtonDetails> actionButtons) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getSectionTitle(context, title),
          Row(children: actionButtons.map((ab) => getPrimaryButton(ab)).toList()),
        ],
      );

  static Widget getPrimaryButton(ButtonDetails actionButton) => TextButton(
        onPressed: actionButton.onTap,
        onLongPress: actionButton.onLongTap,
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
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
            if (actionButton.text != null)
              Text(
                actionButton.text!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
          ],
        ),
      );

  static Widget getOutlinedPrimaryButton(BuildContext context, ButtonDetails actionButton) => OutlinedButton(
        onPressed: actionButton.onTap,
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.shadow),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
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
            if (actionButton.text != null)
              Text(
                actionButton.text!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
          ],
        ),
      );

  static Widget getElevatedPrimaryButton(BuildContext context, ButtonDetails actionButton) => ElevatedButton(
        onPressed: actionButton.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
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
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              ),
          ],
        ),
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

  static Widget getCard(Widget child, {Color? color}) => Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: child,
      );

  static Widget getCompleteMark(BuildContext context, bool complete) => Icon(
        complete ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: complete ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 22,
      );

  static getDefaultDivider() => const Divider(thickness: 0.25);
}
