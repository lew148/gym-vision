import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';

class ButtonDetailsStyle {
  Color? iconColor;
  Color? textColor;

  ButtonDetailsStyle({
    this.iconColor,
    this.textColor,
  });

  static ButtonDetailsStyle primaryIcon(BuildContext context) =>
      ButtonDetailsStyle(iconColor: Theme.of(context).colorScheme.primary);

  static ButtonDetailsStyle primaryIconAndText(BuildContext context) => ButtonDetailsStyle(
      iconColor: Theme.of(context).colorScheme.primary, textColor: Theme.of(context).colorScheme.primary);

  static ButtonDetailsStyle redIcon = ButtonDetailsStyle(iconColor: Colors.red);
  static ButtonDetailsStyle redIconAndText = ButtonDetailsStyle(iconColor: Colors.red, textColor: Colors.red);
}

class ButtonDetails {
  Function()? onTap;
  Function()? onLongTap;
  IconData? icon;
  String? text;
  ButtonDetailsStyle? style;
  bool disabled;

  ButtonDetails({
    this.onTap,
    this.onLongTap,
    this.icon,
    this.text,
    this.style,
    this.disabled = false,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: buttonDetails.map((ab) => getTextButton(ab)).toList(),
          ),
        ],
      );

  static Widget getTextButton(ButtonDetails bd) => TextButton(
        onPressed: bd.disabled ? null : bd.onTap,
        onLongPress: bd.disabled ? null : bd.onLongTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (bd.icon != null)
              Icon(
                bd.icon,
                size: 25,
                color: bd.style?.iconColor,
              ),
            if (bd.icon != null && bd.text != null) const Padding(padding: EdgeInsets.only(left: 5)),
            if (bd.text != null) Text(bd.text!, style: TextStyle(color: bd.style?.textColor)),
          ],
        ),
      );

  static Widget getElevatedPrimaryButton(ButtonDetails bd) => ElevatedButton(
        onPressed: bd.disabled ? null : bd.onTap,
        onLongPress: bd.disabled ? null : bd.onLongTap,
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (bd.icon != null)
              Icon(
                bd.icon,
                color: bd.style?.iconColor,
                size: 25,
              ),
            if (bd.icon != null && bd.text != null) const Padding(padding: EdgeInsets.only(left: 5)),
            if (bd.text != null) Text(bd.text!, style: TextStyle(color: bd.style?.textColor)),
          ],
        ),
      );

  static getDeleteButton(Function() onTap) => getTextButton(getDeleteButtonDetails(onTap));

  static getDeleteButtonDetails(Function() onTap, {String? text}) => ButtonDetails(
        onTap: onTap,
        icon: Icons.delete_rounded,
        text: text,
        style: ButtonDetailsStyle(iconColor: Colors.red),
      );

  static getDoneButton(Function() onSubmit) => CommonUI.getTextButton(
        ButtonDetails(
          onTap: onSubmit,
          text: 'Done',
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

  static getDivider({double? height}) => Divider(thickness: 0.25, height: height);

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

  static getModalMenu(BuildContext context, List<ButtonDetails> options, {String? modalName}) {
    final List<Widget> items = [getSectionTitleWithCloseButton(context, modalName ?? 'Options')];
    items.add(const Padding(padding: EdgeInsets.all(5)));

    for (int i = 0; i < options.length; i++) {
      if (i != 0) items.add(getDivider());
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

  static getRestWidget({Color? color}) => Row(children: [
        Icon(Icons.hotel_rounded, size: 20, color: color),
        const Padding(padding: EdgeInsets.all(2.5)),
        Text('Rest', style: TextStyle(color: color)),
      ]);

  static Widget getSelectedContainer(BuildContext context, {required Widget child, bool selected = false}) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            width: 2,
            color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: child,
      );
}
