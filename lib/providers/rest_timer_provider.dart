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
  static const String restTimerTitle = "Rest is over";
  static const String restTimerBody = "Time to get back to work!";

  DateTime _getNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  Duration getTimeLeft() => _startTime == null || _duration == null
      ? Duration.zero
      : DateTimeHelper.timeBetween(_getNow(), _startTime!.add(_duration!));

  int getPercentageLeft() => _duration == null ? 0 : (getTimeLeft().inSeconds / _duration!.inSeconds * 100).truncate();

  Future<void> clearTimer({Timer? t}) async {
    t?.cancel();
    timer?.cancel();
    _startTime = null;
    _duration = null;
    _timer = null;
    await LocalNotificationService.cancelNotification(iosNotifId);
  }

  void setTimer({required BuildContext context, required Duration duration}) async {
    final globalContext = Provider.of<NavigationProvider>(context, listen: false).getGlobalContext();

    await clearTimer();
    _startTime = DateTime.now();
    _duration = duration;

    if (Platform.isIOS) {
      await LocalNotificationService.scheduleNotification(
        id: iosNotifId,
        title: restTimerTitle,
        body: restTimerBody,
        scheduledTime: _startTime!.add(_duration!),
      );
    }

    _timer = Timer(
      duration,
      () async {
        await clearTimer();

        if (SchedulerBinding.instance.lifecycleState != AppLifecycleState.resumed) {
          // IOS has been set on a timer
          if (Platform.isAndroid) {
            LocalNotificationService.showNotification(title: restTimerTitle, body: restTimerBody);
          }
        } else {
          if (globalContext == null || !globalContext.mounted) return;

          if (Platform.isIOS) {
            await LocalNotificationService.cancelNotification(iosNotifId);
          }

          if (!globalContext.mounted) return;
          final activeWorkoutProvider = Provider.of<ActiveWorkoutProvider>(globalContext, listen: false);

          showCustomDialog(
            globalContext,
            title: restTimerTitle,
            icon: Icons.alarm_on_rounded,
            content: restTimerBody,
            customActions: [
              if (!activeWorkoutProvider.activeWorkoutIsOpen)
                CupertinoDialogAction(
                  child: const Text("Open Workout!"),
                  onPressed: () {
                    Navigator.pop(globalContext);
                    activeWorkoutProvider.openActiveWorkout(globalContext);
                  },
                ),
            ],
          );
        }

        notifyListeners();
      },
    );

    notifyListeners();
  }
}
