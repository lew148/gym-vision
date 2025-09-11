import 'package:flutter/cupertino.dart';
import 'package:gymvision/common/common_ui.dart';

class DateTimePicker extends StatefulWidget {
  final void Function(DateTime dt) onChange;
  final CupertinoDatePickerMode mode;
  final DateTime? initialValue;

  const DateTimePicker({
    super.key,
    required this.onChange,
    required this.mode,
    this.initialValue,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late GlobalKey key;
  late DateTime value;

  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    value = widget.initialValue ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: CupertinoDatePicker(
            key: key,
            initialDateTime: value,
            mode: widget.mode,
            use24hFormat: true,
            onDateTimeChanged: (dt) => setState(() {
              value = dt;
            }),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonUI.getTextButton(ButtonDetails(
              text: 'Now',
              onTap: () => setState(() {
                key = GlobalKey(); // prevent persisting state
                value = DateTime.now();
              }),
            )),
            CommonUI.getDoneButton(() {
              Navigator.pop(context);
              widget.onChange(value);
            }),
          ],
        ),
      ],
    );
  }
}
