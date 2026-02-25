import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:intl/intl.dart';

class StatDisplay extends StatelessWidget {
  final IconData? icon;
  final double? iconSize;
  final String? text;
  final bool muted;
  final Color? color;
  final MainAxisAlignment? alignment;

  const StatDisplay({
    super.key,
    this.icon,
    this.iconSize,
    this.text,
    this.muted = false,
    this.color,
    this.alignment,
  });

  factory StatDisplay.dateTime(DateTime dt) => StatDisplay(
        icon: Icons.calendar_month_rounded,
        text: '${DateFormat(DateTimeHelper.dmyFormat).format(dt)} @ ${DateFormat(DateTimeHelper.hmFormat).format(dt)}',
      );

  factory StatDisplay.date(DateTime dt, {bool muted = true}) => StatDisplay(
        icon: Icons.calendar_month_rounded,
        text: DateFormat(DateTimeHelper.dmyFormat).format(dt),
        muted: muted,
      );

  factory StatDisplay.time(DateTime dt, {DateTime? dtEnd, bool muted = true}) => StatDisplay(
        icon: Icons.access_time_rounded,
        muted: muted,
        text: '${DateTimeHelper.getTimeStr(dt)}${dtEnd == null ? '' : ' - ${DateTimeHelper.getTimeStr(dtEnd)}'}',
      );

  factory StatDisplay.timeElapsed(Duration timeElapsed, {bool muted = true}) => StatDisplay(
        icon: Icons.hourglass_empty_rounded,
        text: DateTimeHelper.getHMSDurationString(timeElapsed),
        muted: muted,
      );

  factory StatDisplay.weight(
    double? weight, {
    MainAxisAlignment? alignment,
    bool useIcon = true,
    bool muted = false,
  }) =>
      StatDisplay(
        icon: useIcon ? Icons.fitness_center_rounded : null,
        text: weight == null || weight == 0 ? null : '${NumberHelper.doubleToString(weight)}kg',
        alignment: alignment,
        muted: muted,
      );

  factory StatDisplay.reps(
    int? reps, {
    MainAxisAlignment? alignment,
    bool useIcon = true,
    bool muted = false,
  }) =>
      StatDisplay(
        icon: useIcon ? Icons.repeat_rounded : null,
        text: reps == null || reps == 0 ? null : '$reps rep${reps == 1 ? '' : 's'}',
        alignment: alignment,
        muted: muted,
      );

  factory StatDisplay.duration(
    Duration? duration, {
    MainAxisAlignment? alignment,
    bool useIcon = true,
  }) =>
      StatDisplay(
        icon: useIcon ? Icons.timer_rounded : null,
        text: duration == null || duration.inSeconds == 0
            ? null
            : DateTimeHelper.getHMSDurationString(
                duration,
                includeSeconds: true,
              ),
        alignment: alignment,
        muted: false,
      );

  factory StatDisplay.distance(
    double? distance, {
    MainAxisAlignment? alignment,
    bool useIcon = true,
  }) =>
      StatDisplay(
        icon: useIcon ? Icons.timeline_rounded : null,
        text: distance == null || distance == 0 ? null : '${NumberHelper.doubleToString(distance)}km',
        alignment: alignment,
        muted: false,
      );

  factory StatDisplay.caloriesBurned(
    int? cals, {
    MainAxisAlignment? alignment,
    bool useIcon = true,
  }) =>
      StatDisplay(
        icon: useIcon ? Icons.local_fire_department_rounded : null,
        text: cals == null || cals == 0 ? null : '${cals}kcals',
        alignment: alignment,
        muted: false,
      );

  factory StatDisplay.rest() => const StatDisplay(icon: Icons.hotel_rounded, iconSize: 20, text: 'Rest');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize ?? 15,
            color: muted ? Theme.of(context).colorScheme.secondary : color,
          ),
          const Padding(padding: EdgeInsets.all(2.5)),
        ],
        Text(
          text ?? '-',
          style: TextStyle(
            fontSize: 15,
            color: text == null || muted ? Theme.of(context).colorScheme.secondary : color,
          ),
        ),
      ],
    );
  }
}
