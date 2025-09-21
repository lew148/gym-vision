import 'package:flutter/cupertino.dart';
import 'package:gymvision/widgets/common_ui.dart';

class DurationPicker extends StatefulWidget {
  final void Function(Duration d) onChange;
  final CupertinoTimerPickerMode mode;
  final Duration? initialValue;
  final bool isTimer;

  const DurationPicker({
    super.key,
    required this.onChange,
    required this.mode,
    this.initialValue,
    this.isTimer = false,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late GlobalKey key;
  late Duration value;

  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    value = widget.initialValue ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: CupertinoTimerPicker(
            key: key,
            initialTimerDuration: value,
            mode: widget.mode,
            onTimerDurationChanged: (d) => setState(() {
              value = d;
            }),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonUI.getTextButton(ButtonDetails(
              text: 'Reset',
              onTap: () => setState(() {
                key = GlobalKey(); // prevent persisting state
                value = Duration.zero;
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
