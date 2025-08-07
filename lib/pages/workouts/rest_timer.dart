import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? uiRefreshTimer;
  RestTimerProvider? provider;
  Duration? left;

  @override
  void initState() {
    super.initState();
    uiRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    uiRefreshTimer?.cancel();
    super.dispose();
  }

  void setTimer(Duration duration) => provider?.setTimer(
        duration: duration,
        callback: () {
          HapticFeedback.heavyImpact();
          HapticFeedback.heavyImpact();
          HapticFeedback.heavyImpact();
        },
      );

  void showPicker() => showDurationPicker(
        context,
        CupertinoTimerPickerMode.ms,
        (Duration d) => setTimer(d),
        isTimer: true,
      );

  void onTimerDelete() => provider?.clearTimer();

  @override
  Widget build(BuildContext context) {
    provider ??= Provider.of<RestTimerProvider>(context);
    return provider?.timer == null
        ? CommonUI.getTextButton(ButtonDetails(
            icon: Icons.av_timer_rounded,
            onTap: showPicker,
          ))
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showDeleteConfirm(context, 'Timer', onTimerDelete, null),
            child: Text(getDurationString(provider!.getTimeLeft())),
          );
  }
}
