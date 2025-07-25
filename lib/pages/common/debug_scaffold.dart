import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/forms/report_bug_form.dart';
import 'package:gymvision/user_settings_view.dart';

class DebugScaffold extends StatefulWidget {
  final Widget body;
  final NavigationBar? bottomNavigationBar;
  final Widget? customAppBarTitle;
  final List<IconButton>? customAppBarActions;
  final bool ignoreDefaults;

  const DebugScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.customAppBarTitle,
    this.customAppBarActions,
    this.ignoreDefaults = false,
  });

  @override
  State<DebugScaffold> createState() => _DebugScaffoldState();
}

class _DebugScaffoldState extends State<DebugScaffold> {
  late List<IconButton> actions;

  @override
  void initState() {
    super.initState();

    actions = widget.customAppBarActions ??
        [
          if (!widget.ignoreDefaults)
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const UserSettingsView()))
                  .then((value) => setState(() {})),
            )
        ];

    actions.insert(
      0,
      IconButton(
        icon: const Icon(Icons.bug_report_outlined),
        onPressed: () => showCustomBottomSheet(context, ReportBugForm(onReportSent: (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success ? 'Report sent!' : 'Failed to send report!'),
          ));
        })),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.customAppBarTitle ?? (widget.ignoreDefaults ? null : const Text('Gymvision')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: actions,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: widget.body),
      ),
    );
  }
}
