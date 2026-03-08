import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/picker_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/forms/fields/custom_field.dart';

class DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final Function(DateTime? newDateTime) onChange;
  final CupertinoDatePickerMode mode;

  const DateTimeField({
    super.key,
    this.dateTime,
    required this.label,
    required this.onChange,
    required this.mode,
  });

  final double _materialFieldPadding = 2.5;
  final double _materialIconToValuePadding = 8.0;

  IconData getIcon() => switch (mode) {
        CupertinoDatePickerMode.date => Icons.calendar_today_rounded,
        CupertinoDatePickerMode.time => Icons.access_time_rounded,
        CupertinoDatePickerMode.dateAndTime => Icons.calendar_today_rounded,
        CupertinoDatePickerMode.monthYear => throw UnimplementedError(),
      };

  String getDisplay() => switch (mode) {
        CupertinoDatePickerMode.date => DateTimeHelper.getDateOrDayStr(dateTime!),
        CupertinoDatePickerMode.time => DateTimeHelper.getTimeStr(dateTime!),
        CupertinoDatePickerMode.dateAndTime =>
          '${DateTimeHelper.getDateOrDayStr(dateTime!)} @ ${DateTimeHelper.getTimeStr(dateTime!)}',
        CupertinoDatePickerMode.monthYear => throw UnimplementedError(),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: _materialFieldPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomField(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => PickerHelper.showDateTimePicker(context, mode, onChange, initialDateTime: dateTime),
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: _materialFieldPadding),
                  child: Row(children: [
                    Icon(getIcon(), color: Theme.of(context).colorScheme.secondary),
                    Padding(padding: EdgeInsetsGeometry.all(_materialIconToValuePadding)),
                    dateTime == null
                        ? Text(label, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary))
                        : Text(getDisplay(), style: const TextStyle(fontSize: 15)),
                  ]),
                ),
              ),
            ),
          ),
          if (dateTime != null)
            Padding(
              padding: const EdgeInsetsGeometry.only(left: 15, right: 5),
              child: Button.clear(useIcon: true, onTap: () => onChange(null)),
            )
        ],
      ),
    );
  }
}
