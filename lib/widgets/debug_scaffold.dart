import 'package:flutter/material.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/active_workout_bar.dart';
import 'package:gymvision/widgets/forms/report_bug_form.dart';
import 'package:gymvision/widgets/pages/user_settings_view.dart';

class DebugScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? customAppBarTitle;
  final List<IconButton>? customAppBarActions;
  final bool ignoreDefaults;
  final bool showActiveWorkout;

  const DebugScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.customAppBarTitle,
    this.customAppBarActions,
    this.ignoreDefaults = false,
    this.showActiveWorkout = false,
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
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserSettingsView())),
            )
        ];

    actions.insert(
      0,
      IconButton(
        icon: const Icon(Icons.bug_report_outlined),
        onPressed: () => showCloseableBottomSheet(
          context,
          ReportBugForm(onReportSent: (success) {
            if (!mounted) return;
            showSnackBar(context, success ? 'Report sent!' : 'Failed to send report!');
          }),
          title: 'Bug/Feature Report',
        ),
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
        onTap: () => closeKeyboard(),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: widget.body),
      ),
      resizeToAvoidBottomInset: false,
      bottomSheet: widget.showActiveWorkout ? const ActiveWorkoutBar() : null,
    );
  }
}
