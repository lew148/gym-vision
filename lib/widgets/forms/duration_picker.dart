import 'package:flutter/cupertino.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';

class DurationPicker extends StatefulWidget {
  final CupertinoTimerPickerMode mode;
  final Function(Duration d)? onSubmit;
  final Function(Duration d)? onChange;
  final Duration? initialValue;
  final bool isTimer;

  const DurationPicker({
    super.key,
    required this.mode,
    this.onSubmit,
    this.onChange,
    this.initialValue,
    this.isTimer = false,
  }) : assert(
          (onChange != null || onSubmit != null) || (onChange == null || onSubmit == null),
          'Must provide EITHER onChange OR onSubmit to DurationPicker',
        );

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

  List<Duration> getSampleDurations() => [
        if (widget.mode != CupertinoTimerPickerMode.ms) const Duration(hours: 1),
        const Duration(minutes: 30),
        const Duration(minutes: 15),
        if (widget.mode != CupertinoTimerPickerMode.hm) ...[
          const Duration(seconds: 30),
          const Duration(seconds: 15),
        ],
      ];

  void onChange(Duration d, {bool fromButton = false}) {
    setState(() {
      if (fromButton) key = GlobalKey(); // new key to flush cache
      value = d;
    });

    if (widget.onChange != null) widget.onChange!(d);
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
            onTimerDurationChanged: onChange,
          ),
        ),
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: getSampleDurations()
                .map((d) => Button(
                      text: DateTimeHelper.getDurationString(d),
                      style: ButtonCustomStyle.noPrimary(),
                      onTap: () => onChange(d, fromButton: true),
                    ))
                .toList(),
          ),
        ),
        if (widget.onSubmit != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button.clear(onTap: () {
                Navigator.pop(context);
                widget.onSubmit!(Duration.zero);
              }),
              Button.done(onTap: () {
                Navigator.pop(context);
                widget.onSubmit!(value);
              })
            ],
          ),
      ],
    );
  }
}
