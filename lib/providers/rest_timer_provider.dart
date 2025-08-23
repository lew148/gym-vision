import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/services/local_notification_service.dart';

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

  Duration getTimeLeft() =>
      _startTime == null || _duration == null ? Duration.zero : DateTimeHelper.timeBetween(_getNow(), _startTime!.add(_duration!));

  int getPercentageLeft() => _duration == null ? 0 : (getTimeLeft().inSeconds / _duration!.inSeconds * 100).truncate();

  void clearTimer() {
    timer?.cancel();
    _startTime = null;
    _duration = null;
    _timer = null;
  }

  void setTimer({required Duration duration, required Function callback}) async {
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
          callback();
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
