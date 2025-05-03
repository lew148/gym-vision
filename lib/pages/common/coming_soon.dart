import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      body: Center(
        child: Text(
          'Coming Soon!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
