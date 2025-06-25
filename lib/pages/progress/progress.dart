import 'package:flutter/material.dart';
import 'package:gymvision/pages/progress/schedules_widget.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SchedulesWidget(),
      ],
    );
  }
}
