import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/pages/homepages/progress/schedules_widget.dart';
import 'package:gymvision/widgets/pages/homepages/progress/templates.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  Widget getPill(IconData icon, String text, GestureTapCallback onTap) => Expanded(
        child: CustomCard(
          padding: EdgeInsets.all(10),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWithIcon(icon: icon, text: text, iconSize: 20, primary: true),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          getPill(
            Icons.description_rounded,
            'Templates',
            () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Templates())),
          ),
          // getPill(
          //   Icons.event_note_rounded,
          //   'Schedules',
          //   () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Schedules())),
          // ),
        ]),
        CustomDivider(),
        SchedulesWidget(),
      ],
    );
  }
}
