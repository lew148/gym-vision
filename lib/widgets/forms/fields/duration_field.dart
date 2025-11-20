import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/functions/picker_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';

class DurationField extends StatelessWidget {
  final String label;
  final Duration duration;
  final Function(Duration newDuration) onChange;
  final bool canClear;

  const DurationField({
    super.key,
    required this.label,
    required this.duration,
    required this.onChange,
    this.canClear = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomCard.field(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => PickerHelper.showDurationPicker(context, CupertinoTimerPickerMode.hms, onChange: onChange),
              child: Row(children: [
                Icon(Icons.timer_rounded, color: Theme.of(context).colorScheme.secondary),
                const Padding(padding: EdgeInsetsGeometry.all(8)), // in line with Material FormField's padding
                duration.inSeconds == 0
                    ? Text(
                        'Duration',
                        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                      )
                    : Text(
                        duration.toString().split('.').first.padLeft(8, "0"),
                        style: const TextStyle(fontSize: 15),
                      ),
              ]),
            ),
          ),
        ),
        if (canClear)
          Padding(
            padding: const EdgeInsetsGeometry.only(left: 15, right: 5),
            child: Button.clear(onTap: () => onChange(Duration.zero)),
          )
      ],
    );
  }
}
