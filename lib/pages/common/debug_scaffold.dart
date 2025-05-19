import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/forms/report_bug_form.dart';
import 'package:gymvision/user_settings_view.dart';

class DebugScaffold extends StatefulWidget {
  final Widget body;
  final NavigationBar? bottomNavigationBar;
  final AppBar? customAppBar;

  const DebugScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.customAppBar,
  });

  @override
  State<DebugScaffold> createState() => _DebugScaffoldState();
}

class _DebugScaffoldState extends State<DebugScaffold> {
  late AppBar appBar;

  @override
  void initState() {
    super.initState();

    appBar = widget.customAppBar ??
        AppBar(
          title: const Text('Gymvision'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const UserSettingsView()))
                  .then((value) => setState(() {})),
            )
          ],
        );

    appBar.actions?.insert(
      0,
      IconButton(
        icon: const Icon(Icons.bug_report_outlined),
        onPressed: () => CommonFunctions.showBottomSheet(context, const ReportBugForm()).then((value) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent!')));
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: widget.body),
      ),
    );
  }
}
