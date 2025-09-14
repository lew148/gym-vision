import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:provider/provider.dart';

class RestTimerProvider extends ChangeNotifier {
  DateTime? _startTime;
  Duration? _duration;
  Timer? _timer;

  Timer? get timer => _timer;

  static const int iosNotifId = 11;
  static const String restTimerTitle = "Rest is over!";
  static const String restTimerBody = "Time to get back to work";

  DateTime _getNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  Duration getTimeLeft() => _startTime == null || _duration == null
      ? Duration.zero
      : DateTimeHelper.timeBetween(_getNow(), _startTime!.add(_duration!));

  int getPercentageLeft() => _duration == null ? 0 : (getTimeLeft().inSeconds / _duration!.inSeconds * 100).truncate();

  void clearTimer({Timer? t}) {
    t?.cancel();
    timer?.cancel();
    _startTime = null;
    _duration = null;
    _timer = null;
  }

  void setTimer({required BuildContext context, required Duration duration}) async {
    final globalContext = Provider.of<NavigationProvider>(context, listen: false).getGlobalContext();

    clearTimer();
    _startTime = DateTime.now();
    _duration = duration;
    _timer = Timer(
      duration,
      () async {
        clearTimer();

        if (SchedulerBinding.instance.lifecycleState != AppLifecycleState.resumed) {
          if (Platform.isAndroid) {
            LocalNotificationService.showNotification(title: restTimerTitle, body: restTimerBody);
          }
        } else {
          if (globalContext == null || !globalContext.mounted) return;

          if (Platform.isIOS) {
            await LocalNotificationService.cancelNotification(iosNotifId);
          }

          if (!globalContext.mounted) return;

          showCustomDialog(
            globalContext,
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.alarm_on_rounded),
              Padding(padding: EdgeInsetsGeometry.all(2.5)),
              Text(restTimerTitle),
            ]),
            const Text(restTimerBody),
            actions: [
              CupertinoDialogAction(
                child: const Text("Let's go!"),
                onPressed: () {
                  Navigator.pop(globalContext);
                  final activeWorkoutProvider = Provider.of<ActiveWorkoutProvider>(globalContext, listen: false);
                  if (!activeWorkoutProvider.isActiveWorkoutBarOpen) {
                    activeWorkoutProvider.openActiveWorkout(globalContext);
                  }
                },
              ),
            ],
          );
        }

        notifyListeners();
      },
    );

    if (Platform.isIOS) {
      await LocalNotificationService.scheduleNotification(
        id: iosNotifId,
        title: restTimerTitle,
        body: restTimerBody,
        scheduledTime: _startTime!.add(_duration!),
      );
    }

    notifyListeners();
  }
}
