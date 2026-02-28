import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

class ToastHelper {
  static Future<void> showToast(
    BuildContext context, {
    required String message,
    String? subtitle,
    Icon? icon,
    Color? color,
    Duration? duration,
    bool dontRemoveOthers = false,
  }) async {
    if (!dontRemoveOthers) DelightToastBar.removeAll();

    DelightToastBar(
      animationCurve: Curves.easeOutExpo,
      animationDuration: const Duration(milliseconds: 100),
      autoDismiss: true,
      snackbarDuration: duration ?? const Duration(seconds: 3),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 20), // to avoid overlapping with bottom navigation bar
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ToastCard(
            leading: icon ?? Icon(Icons.info_outline),
            title: Text(message),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  )
                : null,
            color: color ?? Color(0xFF262626),
          ),
        ),
      ),
    ).show(context);
  }

  static Future<void> showSuccessToast(BuildContext context, {required String message, String? subtitle}) async =>
      showToast(
        context,
        message: message,
        subtitle: subtitle,
        icon: Icon(Icons.check_circle_rounded, color: Colors.green),
      );

  static Future<void> showFailureToast(BuildContext context, {required String message, String? subtitle}) async =>
      showToast(
        context,
        message: message,
        subtitle: subtitle ?? 'Please try again later.',
        icon: Icon(Icons.error_rounded, color: Colors.red),
      );

  static Future<void> showDisallowedToast(BuildContext context, {required String message, String? subtitle}) async =>
      showToast(
        context,
        message: message,
        subtitle: subtitle,
        icon: Icon(Icons.do_not_disturb_rounded, color: Colors.red),
      );
}
