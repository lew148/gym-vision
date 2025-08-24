import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';

class RestTimer extends StatefulWidget {
  final int? workoutId;

  const RestTimer({
    super.key,
    this.workoutId,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late RestTimerProvider restTimerProvider;
  Timer? uiRefreshTimer;
  Duration? left;
  int? workoutId;
  bool leftWorkoutScreen = false;

  @override
  void initState() {
    super.initState();
    workoutId = widget.workoutId;
    uiRefreshTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (Timer t) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    uiRefreshTimer?.cancel();
    super.dispose();
    leftWorkoutScreen = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    restTimerProvider = Provider.of<RestTimerProvider>(context);
  }


  void showPicker() => showDurationPicker(
        context,
        CupertinoTimerPickerMode.ms,
        (Duration d) => restTimerProvider.setTimer(context: context, duration: d),
        isTimer: true,
      );

  void onTimerDelete() => restTimerProvider.clearTimer();

  @override
  Widget build(BuildContext context) {
    return restTimerProvider.timer == null
        ? CommonUI.getTextButton(ButtonDetails(
            icon: Icons.alarm_add_rounded,
            onTap: showPicker,
          ))
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showDeleteConfirm(context, 'Timer', onTimerDelete, null),
            child: Stack(children: [
              Container(
                height: 25,
                width: 50 * (restTimerProvider.getPercentageLeft() / 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.shadow),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                height: 25,
                width: 50,
                child: Center(
                  child: Text(
                    DateTimeHelper.getDurationString(restTimerProvider.getTimeLeft(), noHours: true),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          );
  }
}
