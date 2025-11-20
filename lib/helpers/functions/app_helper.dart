import 'package:flutter/material.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
import 'package:provider/provider.dart';

class AppHelper {
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static void showSnackBar(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static void setRestTimer(BuildContext context, Duration duration) =>
      Provider.of<RestTimerProvider>(context, listen: false).setTimer(context: context, duration: duration);
}
