import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/picker_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';

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

  final double _adjustmentPadding = 2.5;

  Widget getIcon() => switch (mode) {
        CupertinoDatePickerMode.date => const Icon(Icons.calendar_today_rounded),
        CupertinoDatePickerMode.time => const Icon(Icons.access_time_rounded),
        CupertinoDatePickerMode.dateAndTime => const Icon(Icons.calendar_today_rounded),
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
      padding: EdgeInsetsGeometry.symmetric(vertical: _adjustmentPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomCard.field(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => PickerHelper.showDateTimePicker(context, mode, onChange, initialDateTime: dateTime),
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: _adjustmentPadding),
                  child: Row(children: [
                    getIcon(),
                    const Padding(padding: EdgeInsetsGeometry.all(8)), // in line with Material FormField's padding
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
