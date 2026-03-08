import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';

class DialogHelper {
  static Future showDeleteConfirm(BuildContext context, String objectName, Function onDelete) async {
    HapticFeedback.heavyImpact();
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Delete $objectName?"),
        content: Text("Are you sure you would like to delete this $objectName?"),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                await onDelete();
                if (context.mounted) ToastHelper.showSuccessToast(context, message: 'Successfully deleted $objectName');
              } catch (ex) {
                if (!context.mounted) return;
                ToastHelper.showFailureToast(context, message: 'Failed to delete $objectName!');
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    Function? onConfirm,
    String? content,
  }) async {
    HapticFeedback.heavyImpact();
    var confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: content == null ? null : Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'Confirm',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context);
              confirmed = true;
              if (onConfirm != null) onConfirm();
            },
          ),
        ],
      ),
    );

    return confirmed;
  }

  static Future showCustomDialog(
    BuildContext context, {
    required String title,
    IconData? icon,
    Widget? content,
    List<CupertinoDialogAction>? customActions,
    bool dismissable = true,
  }) async {
    HapticFeedback.heavyImpact();
    await showDialog(
      context: context,
      barrierDismissible: dismissable,
      builder: (context) => CupertinoAlertDialog(
          title: icon == null
              ? Text(title)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.primary),
                    const Padding(padding: EdgeInsetsGeometry.all(2.5)),
                    Text(title),
                  ],
                ),
          content: Padding(padding: EdgeInsetsGeometry.only(top: 10), child: content),
          actions: [
            if (customActions != null) ...customActions,
            if (dismissable)
              CupertinoDialogAction(
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context),
              ),
          ]),
    );
  }
}
