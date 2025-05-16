import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/forms/report_bug_form.dart';
import 'package:gymvision/user_settings_view.dart';

class DebugScaffold extends StatefulWidget {
  final Widget body;
  final NavigationBar? bottomNavigationBar;

  const DebugScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
  });

  @override
  State<DebugScaffold> createState() => _DebugScaffoldState();
}

class _DebugScaffoldState extends State<DebugScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gymvision'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => CommonFunctions.showBottomSheet(context, const ReportBugForm()).then((value) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent!')));
            }),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const UserSettingsView()))
                .then((value) => setState(() {})),
          )
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: widget.body),
      ),
    );
  }
}
