import 'package:flutter/material.dart';

class AppHelper {
  static const String appVersion = '1.0.8';

  static const darkPropOnCardColor = Color.fromARGB(255, 60, 60, 60);

  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
