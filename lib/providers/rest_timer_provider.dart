import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:provider/provider.dart';

class RestTimerProvider extends ChangeNotifier {
  DateTime? _startTime;
  Duration? _duration;
  Timer? _timer;

  Timer? get timer => _timer;

  static const String restTimerTitle = "Rest Time Over!";
  static const String restTimerBody = "Let's get back to work.";

  DateTime _getNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  Duration getTimeLeft() => _startTime == null || _duration == null
      ? Duration.zero
      : DateTimeHelper.timeBetween(_getNow(), _startTime!.add(_duration!));

  int getPercentageLeft() => _duration == null ? 0 : (getTimeLeft().inSeconds / _duration!.inSeconds * 100).truncate();

  void clearTimer() {
    timer?.cancel();
    _startTime = null;
    _duration = null;
    _timer = null;
  }

  void setTimer({required BuildContext context, required Duration duration}) async {
    final globalContext = Provider.of<NavigationProvider>(context, listen: false).getGlobalContext();

    _startTime = DateTime.now();
    _duration = duration;
    _timer = Timer.periodic(
      duration,
      (Timer t) {
        clearTimer();

        if (SchedulerBinding.instance.lifecycleState != AppLifecycleState.resumed) {
          if (Platform.isAndroid) {
            LocalNotificationService.showNotification(title: restTimerTitle, body: restTimerBody);
          }
        } else {
          if (globalContext == null || !globalContext.mounted) return;
          showCustomDialog(
            globalContext,
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.alarm_on_rounded),
              Padding(padding: EdgeInsetsGeometry.all(2.5)),
              Text('Rest Over!'),
            ]),
            Column(children: [
              const Text('Time to get back to work!'),
              Text('Return to active workout?', style: TextStyle(color: Theme.of(globalContext).colorScheme.shadow)),
            ]),
            actions: [
              CupertinoDialogAction(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(globalContext);
                },
              ),
              // if (workoutId != null && leftWorkoutScreen)
              //   CupertinoDialogAction(
              //     child: Text(
              //       'Go',
              //       style: TextStyle(
              //         color: Theme.of(globalContext).colorScheme.primary,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     onPressed: () {
              //       Navigator.pop(globalContext);
              //       openWorkoutView(globalContext, workoutId!);
              //     },
              //   ),
            ],
          );
        }

        notifyListeners();
      },
    );

    if (Platform.isIOS) {
      await LocalNotificationService.scheduleNotification(
        title: restTimerTitle,
        body: restTimerBody,
        scheduledTime: _startTime!.add(_duration!),
      );
    }

    notifyListeners();
  }
}
