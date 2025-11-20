import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';

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
            child: const Text("Keep"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                await onDelete();
              } catch (ex) {
                if (!context.mounted) return;
                AppHelper.showSnackBar(context, 'Failed to delete $objectName: ${ex.toString()}');
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
    String? content,
    List<CupertinoDialogAction>? customActions,
    bool includeOK = true,
  }) async {
    HapticFeedback.heavyImpact();
    await showDialog(
      context: context,
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
          content: (content == null ? null : Text(content)),
          actions: [
            if (customActions != null) ...customActions,
            if (includeOK)
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
