import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/forms/report_bug_form.dart';

class DebugScaffold extends StatefulWidget {
  final Widget body;
  final AppBar? appBar;
  final NavigationBar? bottomNavigationBar;

  const DebugScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  State<DebugScaffold> createState() => _DebugScaffoldState();
}

class _DebugScaffoldState extends State<DebugScaffold> {
  @override
  Widget build(BuildContext context) {
    widget.appBar?.actions?.insert(
      0,
      IconButton(
        icon: const Icon(Icons.bug_report_outlined),
        onPressed: () => CommonFunctions.showBottomSheet(context, const ReportBugForm()),
      ),
    );

    return Scaffold(
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: widget.body,
    );
  }
}
