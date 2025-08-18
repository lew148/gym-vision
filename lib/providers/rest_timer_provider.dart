import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/local_notification_service.dart';

class RestTimerProvider extends ChangeNotifier {
  DateTime? _startTime;
  Duration? _duration;
  Timer? _timer;

  Timer? get timer => _timer;

  DateTime _getNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  Duration getTimeLeft() =>
      _startTime == null || _duration == null ? Duration.zero : timeBetween(_getNow(), _startTime!.add(_duration!));

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
        callback();
        notifyListeners();
      },
    );

    await LocalNotificationService.scheduleNotification(
      title: 'Rest Timer Up!',
      body: 'Time to get back to work.',
      scheduledTime: _startTime!.add(_duration!),
    );

    notifyListeners();
  }
}
