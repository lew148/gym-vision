import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:intl/intl.dart';

class ButtonDetailsStyle {
  Color? textColor;
  Color? iconColor;
  double? iconSize;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;

  ButtonDetailsStyle({
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.padding,
  });

  static ButtonDetailsStyle primaryIcon(BuildContext context) =>
      ButtonDetailsStyle(iconColor: Theme.of(context).colorScheme.primary);

  static ButtonDetailsStyle primaryIconAndText(BuildContext context) => ButtonDetailsStyle(
        iconColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.primary,
      );

  static ButtonDetailsStyle noPadding = ButtonDetailsStyle(padding: EdgeInsets.zero);
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
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
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
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
        child: Row(
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
        ),
      );

  static Widget getSectionTitleWithAction(BuildContext context, String title, ButtonDetails buttonDetails) =>
      getSectionTitleWithActions(context, title, [buttonDetails]);

  static Widget getSectionTitleWithActions(BuildContext context, String title, List<ButtonDetails> buttonDetails) =>
      getSectionWidgetWithActions(context, getSectionTitle(context, title), buttonDetails);

  static Widget getSectionWidgetWithAction(BuildContext context, Widget widget, ButtonDetails buttonDetail) =>
      getSectionWidgetWithActions(context, widget, [buttonDetail]);

  static Widget getSectionWidgetWithActions(BuildContext context, Widget widget, List<ButtonDetails> buttonDetails) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttonDetails.map((ab) => getTextButton(ab)).toList(),
            ),
          ],
        ),
      );

  static Widget getTextButton(ButtonDetails bd) => Padding(
        padding: const EdgeInsetsGeometry.all(2.5),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: bd.style?.backgroundColor,
            padding: bd.style?.padding ?? const EdgeInsets.all(10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            overlayColor: Colors.grey,
          ),
          onPressed: bd.disabled ? null : bd.onTap,
          onLongPress: bd.disabled ? null : bd.onLongTap,
          child: Row(
            children: [
              if (bd.icon != null) Icon(bd.icon, size: bd.style?.iconSize ?? 25, color: bd.style?.iconColor),
              if (bd.icon != null && bd.text != null) const Padding(padding: EdgeInsets.only(left: 2.5)),
              if (bd.text != null) Text(bd.text!, style: TextStyle(color: bd.style?.textColor)),
            ],
          ),
        ),
      );

  static Widget getElevatedPrimaryButton(ButtonDetails bd) => Padding(
        padding: const EdgeInsetsGeometry.all(2.5),
        child: ElevatedButton(
          onPressed: bd.disabled ? null : bd.onTap,
          onLongPress: bd.disabled ? null : bd.onLongTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bd.style?.backgroundColor,
            padding: bd.style?.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.padded,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            overlayColor: Colors.grey,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bd.icon != null) Icon(bd.icon, color: bd.style?.iconColor, size: 25),
              if (bd.icon != null && bd.text != null) const Padding(padding: EdgeInsets.only(left: 5)),
              if (bd.text != null) Text(bd.text!, style: TextStyle(color: bd.style?.textColor)),
            ],
          ),
        ),
      );

  static getDeleteButton(Function() onTap) => getTextButton(getDeleteButtonDetails(onTap));

  static getDeleteButtonDetails(Function() onTap, {String? text}) => ButtonDetails(
        onTap: onTap,
        icon: Icons.delete_rounded,
        text: text,
        style: ButtonDetailsStyle(iconColor: Colors.red),
      );

  static getDoneButton(Function() onSubmit, {bool isAdd = false}) => CommonUI.getTextButton(ButtonDetails(
        onTap: onSubmit,
        text: isAdd ? 'Add' : 'Done',
      ));

  static getDoneButtonRow(Function() onSubmit) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          getTextButton(ButtonDetails(
            onTap: onSubmit,
            text: 'Done',
          )),
        ],
      );

  static Widget getPropDisplay(BuildContext context, String text, {Function()? onTap, Color? color}) => getCard(
        context,
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.all(10),
            child: onTap == null
                ? Text(text)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
          ),
        ),
      );

  static Widget getBigPropDisplay(BuildContext context, String text, {Function()? onTap, Color? color}) => getCard(
        context,
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.all(10),
            child: onTap == null
                ? Text(text, style: const TextStyle(fontSize: 18))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
          ),
        ),
      );

  static Widget getSmallPropDisplay(BuildContext context, String text, {Function()? onTap, Color? color}) => getCard(
        context,
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.all(5),
            child: onTap == null
                ? Text(text)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text),
                      Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.shadow, size: 15),
                    ],
                  ),
          ),
        ),
      );

  static Widget getCard(BuildContext context, Widget child, {Color? color}) => Card.filled(
        margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: 0.25),
        ),
        child: child,
      );

  static Widget getCompleteMark(BuildContext context, bool complete) => Icon(
        complete ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: complete ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 22,
      );

  static getDivider({double? height}) => Divider(thickness: 0.25, height: height);
  static getShadowDivider(BuildContext context, {double? height}) => Divider(
        color: Theme.of(context).colorScheme.shadow,
        thickness: 0.25,
        height: height,
      );

  static getVerticalDivider(BuildContext context, {double? thickness, Color? color}) =>
      VerticalDivider(thickness: thickness ?? 0.25, color: color ?? Theme.of(context).colorScheme.shadow);

  static getInfoWidget(BuildContext context, String title, Widget? info) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.secondary),
            ),
            info ?? getDash()
          ],
        ),
      );

  static getDateTimeWithIcon(BuildContext context, DateTime dt) => Row(children: [
        Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.secondary, size: 15),
        const Padding(padding: EdgeInsetsGeometry.all(2.5)),
        Text(
          '${DateFormat(DateTimeHelper.dmyFormat).format(dt)} @ ${DateFormat(DateTimeHelper.hmFormat).format(dt)}',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15),
        ),
      ]);

  static getDateWithIcon(BuildContext context, DateTime dt) => Row(children: [
        Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.secondary, size: 15),
        const Padding(padding: EdgeInsetsGeometry.all(2.5)),
        Text(
          DateFormat(DateTimeHelper.dmyFormat).format(dt),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15),
        ),
      ]);

  static getTimeWithIcon(BuildContext context, DateTime dt, {DateTime? dtEnd}) => Row(children: [
        Icon(Icons.access_time_rounded, color: Theme.of(context).colorScheme.secondary, size: 15),
        const Padding(padding: EdgeInsetsGeometry.all(2.5)),
        Text(
          '${DateFormat(DateTimeHelper.hmFormat).format(dt)}${dtEnd == null ? '' : ' - ${DateFormat(DateTimeHelper.hmFormat).format(dtEnd)}'}',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15),
        ),
      ]);

  static getTimeElapsedWithIcon(BuildContext context, Duration timeElapsed) => Row(children: [
        Icon(Icons.hourglass_empty_rounded, color: Theme.of(context).colorScheme.secondary, size: 15),
        const Padding(padding: EdgeInsetsGeometry.all(2.5)),
        Text(
          DateTimeHelper.getHoursAndMinsDurationString(timeElapsed),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 15,
          ),
        ),
      ]);

  static getWeightWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.fitness_center_rounded, set.hasWeight() ? set.getWeightDisplay() : null);

  static getRepsWithIcon(WorkoutSet set) =>
      getXwithIcon(Icons.repeat_rounded, set.hasReps() ? set.getRepsDisplay() : null);

  static getSetTimeWithIcon(WorkoutSet set) =>
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
          const Padding(padding: EdgeInsets.all(2.5)),
          str == null ? getDash() : Text(str)
        ],
      );

  static getDash() => const Text('-');

  static getModalMenu(BuildContext context, List<ButtonDetails> options, {String? modalName}) {
    final List<Widget> items = [];
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

  static Widget getElevatedButtonsMenu(BuildContext context, List<ButtonDetails> buttons) =>
      Column(children: buttons.map<Widget>((bd) => getElevatedPrimaryButton(bd)).toList());

  static Widget getDragHandle(BuildContext context) => SizedBox(
        width: 100,
        child: Divider(
          color: Theme.of(context).colorScheme.shadow,
          thickness: 4,
          radius: const BorderRadius.all(Radius.circular(25)),
        ),
      );
}
