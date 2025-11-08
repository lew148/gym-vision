import 'package:flutter/material.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';

class Schedules extends StatelessWidget {
  const Schedules({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      customAppBarTitle: Text('Schedules'),
      body: Center(
        child: Text("Schedules Page"),
      ),
    );
  }
}