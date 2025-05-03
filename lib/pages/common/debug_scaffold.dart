import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';

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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CommonFunctions.showBottomSheet(
            context,
            Column(children: [
              CommonUI.getSectionTitleWithCloseButton(context, 'Bug Report / Feature Request'),
              CommonUI.getDefaultDivider(),
              // todo
            ]),
          );
        },
        child: const Icon(Icons.bug_report_outlined),
      ),
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: widget.body,
    );
  }
}
