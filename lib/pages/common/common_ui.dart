import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_set.dart';

class ButtonDetailsStyle {
  Color? iconColor;
  Color? textColor;

  ButtonDetailsStyle({
    this.iconColor,
    this.textColor,
  });
}

class ButtonDetails {
  Function()? onTap;
  Function()? onLongTap;
  IconData? icon;
  String? text;
  ButtonDetailsStyle? style;

  ButtonDetails({
    this.onTap,
    this.onLongTap,
    this.icon,
    this.text,
    this.style,
  });
}

class CommonUI {
  static Widget getSectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
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
          ),
        ],
      );

  static Widget getSectionTitleWithAction(BuildContext context, String title, ButtonDetails buttonDetails) =>
      getSectionTitleWithActions(context, title, [buttonDetails]);

  static Widget getSectionTitleWithActions(BuildContext context, String title, List<ButtonDetails> buttonDetails) =>
      getSectionWidgetWithActions(context, getSectionTitle(context, title), buttonDetails);

  static Widget getSectionWidgetWithAction(BuildContext context, Widget widget, ButtonDetails buttonDetail) =>
      getSectionWidgetWithActions(context, widget, [buttonDetail]);

  static Widget getSectionWidgetWithActions(BuildContext context, Widget widget, List<ButtonDetails> buttonDetails) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget,
          Row(children: buttonDetails.map((ab) => getTextButton(ab)).toList()),
        ],
      );

  static Widget getTextButton(ButtonDetails buttonDetails) => TextButton(
        onPressed: buttonDetails.onTap,
        onLongPress: buttonDetails.onLongTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (buttonDetails.icon != null)
              Icon(
                buttonDetails.icon,
                size: 25,
                color: buttonDetails.style?.iconColor,
              ),
            if (buttonDetails.icon != null && buttonDetails.text != null)
              const Padding(padding: EdgeInsets.only(left: 5)),
            if (buttonDetails.text != null)
              Text(buttonDetails.text!, style: TextStyle(color: buttonDetails.style?.textColor)),
          ],
        ),
      );

  static Widget getElevatedPrimaryButton(ButtonDetails buttonDetails) => ElevatedButton(
        onPressed: buttonDetails.onTap,
        onLongPress: buttonDetails.onLongTap,
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (buttonDetails.icon != null)
              Icon(
                buttonDetails.icon,
                color: buttonDetails.style?.iconColor,
                size: 25,
              ),
            if (buttonDetails.icon != null && buttonDetails.text != null)
              const Padding(padding: EdgeInsets.only(left: 5)),
            if (buttonDetails.text != null)
              Text(buttonDetails.text!, style: TextStyle(color: buttonDetails.style?.textColor)),
          ],
        ),
      );

  static getDeleteButton(void Function() onTap) => TextButton(
        onPressed: onTap,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
          size: 25,
        ),
      );

  static Widget getPropDisplay(BuildContext context, String text, {Function()? onTap}) => getCard(
        context,
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.all(10),
            child: onTap == null
                ? Text(text)
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(text),
                    const Icon(Icons.chevron_right_rounded),
                  ]),
          ),
        ),
      );

  static Widget getCard(BuildContext context, Widget child, {Color? color}) =>
      Theme.of(context).brightness == Brightness.dark
          ? Card.filled(
              margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
              color: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: child,
            )
          : Card(
              margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
              color: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: child,
            );

  static Widget getCompleteMark(BuildContext context, bool complete) => Icon(
        complete ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: complete ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 22,
      );

  static getDefaultDivider() => const Divider(thickness: 0.25);

  static getInfoWidget(BuildContext context, String title, Widget? info) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.shadow),
            ),
            info ?? getDash()
          ],
        ),
      );

  static getWeightWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.fitness_center_rounded, set.hasWeight() ? set.getWeightDisplay() : null);

  static getRepsWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.repeat_rounded, set.hasReps() ? set.getRepsDisplay() : null);

  static getTimeWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.timer_rounded, set.hasTime() ? set.getTimeDisplay() : null);

  static getDistanceWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.timeline_rounded, set.hasDistance() ? set.getDistanceDisplay() : null);

  static getCaloriesWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.local_fire_department_rounded, set.hasCalsBurned() ? set.getCalsBurnedDisplay() : null);

  static getXwithIcon(IconData icon, String? str) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const Padding(padding: EdgeInsets.all(1)),
          str == null ? getDash() : Text(str)
        ],
      );

  static getDash() => const Text('-');

  static getModalMenu(BuildContext context, List<ButtonDetails> options) {
    final List<Widget> items = [getSectionTitleWithCloseButton(context, 'Options')];
    items.add(const Padding(padding: EdgeInsets.all(5)));

    for (int i = 0; i < options.length; i++) {
      if (i != 0) items.add(getDefaultDivider());
      items.add(
        Padding(
          padding: const EdgeInsets.all(5),
          child: InkWell(
            onTap: options[i].onTap,
            child: Row(
              children: [
                Icon(options[i].icon, color: options[i].style?.iconColor),
                const Padding(padding: EdgeInsets.all(5)),
                Text(options[i].text!, style: TextStyle(color: options[i].style?.textColor)),
              ],
            ),
          ),
        ),
      );
    }

    items.add(const Padding(padding: EdgeInsets.all(5)));
    return Column(children: items);
  }
}
