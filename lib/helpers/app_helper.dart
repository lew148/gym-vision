import 'package:flutter/material.dart';

class AppHelper {
  static const String appVersion = '1.0.11';

  static const darkPropOnCardColor = Color.fromARGB(255, 30, 30, 30);

  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
