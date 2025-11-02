import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/text_with_icon.dart';
import 'package:gymvision/widgets/pages/homepages/progress/schedules.dart';
import 'package:gymvision/widgets/pages/homepages/progress/schedules_widget.dart';
import 'package:gymvision/widgets/pages/homepages/progress/templates.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SchedulesWidget(),
        CustomDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomCard(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (BuildContext context) => const Templates())),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWithIcon(icon: Icons.description_rounded, text: "Templates", iconSize: 20, primary: true),
                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
            CustomCard(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (BuildContext context) => const Schedules())),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWithIcon(icon: Icons.event_note_rounded, text: "Schedules", iconSize: 20, primary: true),
                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
