import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';

class RestTimer extends StatefulWidget {
  const RestTimer({super.key});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late RestTimerProvider provider;
  Timer? uiRefreshTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    uiRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<RestTimerProvider>(context);
    if (provider.getTimeLeft().inSeconds != 0) {
      uiRefreshTimer ??= Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
        setState(() {});
        if (provider.getTimeLeft() == Duration.zero) {
          t.cancel();
          uiRefreshTimer = null;
        }
      });
    } else {
      uiRefreshTimer = null;
    }
  }

  void showPicker() => showDurationPicker(
        context,
        CupertinoTimerPickerMode.ms,
        onSubmit: (Duration d) => provider.setTimer(context: context, duration: d),
        isTimer: true,
      );

  void onTimerDelete() async => await provider.clearTimer();

  @override
  Widget build(BuildContext context) {
    return provider.timer == null
        ? Button(
            icon: Icons.alarm_add_rounded,
            onTap: showPicker,
          )
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async => await showDeleteConfirm(context, 'Timer', onTimerDelete),
            child: Stack(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 25,
                width: 60 * (provider.getPercentageLeft() / 100),
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
                width: 60,
                child: Center(
                  child: Text(DateTimeHelper.getDurationString(
                    provider.getTimeLeft(),
                    noHours: true,
                  )),
                ),
              ),
            ]),
          );
  }
}
