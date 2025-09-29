import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:intl/intl.dart';

class TextWithIcon extends StatelessWidget {
  final IconData icon;
  final double? iconSize;
  final String? text;
  final bool muted;
  final MainAxisAlignment? alignment;

  const TextWithIcon({
    super.key,
    required this.icon,
    this.iconSize,
    this.text,
    this.muted = true,
    this.alignment,
  });

  factory TextWithIcon.dateTime(DateTime dt) => TextWithIcon(
        icon: Icons.calendar_month_rounded,
        text: '${DateFormat(DateTimeHelper.dmyFormat).format(dt)} @ ${DateFormat(DateTimeHelper.hmFormat).format(dt)}',
      );

  factory TextWithIcon.date(DateTime dt, {bool muted = true}) => TextWithIcon(
        icon: Icons.calendar_month_rounded,
        text: DateFormat(DateTimeHelper.dmyFormat).format(dt),
        muted: muted,
      );

  factory TextWithIcon.time(DateTime dt, {DateTime? dtEnd}) => TextWithIcon(
        icon: Icons.access_time_rounded,
        text:
            '${DateFormat(DateTimeHelper.hmFormat).format(dt)}${dtEnd == null ? '' : ' - ${DateFormat(DateTimeHelper.hmFormat).format(dtEnd)}'}',
      );

  factory TextWithIcon.timeElapsed(Duration timeElapsed) => TextWithIcon(
        icon: Icons.hourglass_empty_rounded,
        text: DateTimeHelper.getHoursAndMinsDurationString(timeElapsed),
      );

  factory TextWithIcon.weight(double? weight, {MainAxisAlignment? alignment}) => TextWithIcon(
        icon: Icons.fitness_center_rounded,
        text: weight == null ? null : '${NumberHelper.truncateDouble(weight)}kg',
        alignment: alignment,
        muted: false,
      );

  factory TextWithIcon.reps(int? reps, {MainAxisAlignment? alignment}) => TextWithIcon(
        icon: Icons.repeat_rounded,
        text: reps == null || reps == 0 ? 'No Reps' : '$reps rep${reps == 1 ? '' : 's'}',
        alignment: alignment,
        muted: false,
      );

  factory TextWithIcon.setTime(Duration? time, {MainAxisAlignment? alignment}) => TextWithIcon(
        icon: Icons.timer_rounded,
        text: time == null || time.inSeconds == 0 ? '00.00.00' : time.toString().split('.').first.padLeft(8, "0"),
        alignment: alignment,
        muted: false,
      );

  factory TextWithIcon.distance(double? distance, {MainAxisAlignment? alignment}) => TextWithIcon(
        icon: Icons.timeline_rounded,
        text: '${distance == null || distance == 0 ? 0 : distance.toStringAsFixed(2)}km',
        alignment: alignment,
        muted: false,
      );

  factory TextWithIcon.caloriesBurned(int? cals, {MainAxisAlignment? alignment}) => TextWithIcon(
        icon: Icons.local_fire_department_rounded,
        text: '${cals == null || cals == 0 ? 0 : cals}kcals',
        alignment: alignment,
        muted: false,
      );

  factory TextWithIcon.rest() => const TextWithIcon(icon: Icons.hotel_rounded, iconSize: 20, text: 'Rest');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize ?? 15, color: muted ? Theme.of(context).colorScheme.secondary : null),
        const Padding(padding: EdgeInsets.all(2.5)),
        Text(
          text ?? '-',
          style: TextStyle(
            fontSize: 15,
            color: muted ? Theme.of(context).colorScheme.secondary : null,
          ),
        ),
      ],
    );
  }
}
