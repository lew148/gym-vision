import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/drag_handle.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';

class BottomSheetHelper {
  static Future showCloseableBottomSheet(BuildContext context, Widget child, {String? title}) async =>
      await showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        useSafeArea: true,
        isScrollControlled: true,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(largeBorderRadius)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                5,
                20,
                MediaQuery.of(context).viewInsets.bottom > 0
                    ? 10 + MediaQuery.of(context).viewInsets.bottom
                    : 30, // add viewInsets.bottom for keyboard space
              ),
              child: Column(children: [
                const DragHandle(),
                if (title != null) ...[
                  Header(title: title),
                  const CustomDivider(),
                ],
                child,
              ]),
            ),
          ],
        ),
      );

  static Future showFullScreenBottomSheet(BuildContext context, {required Widget child, bool closable = false}) async =>
      await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        enableDrag: closable,
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        builder: (BuildContext context) => Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(largeBorderRadius)),
          ),
          padding: EdgeInsets.fromLTRB(
            10,
            10,
            10,
            MediaQuery.of(context).viewInsets.bottom, // for keyboard space
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Column(children: [
              if (closable) const DragHandle(),
              Expanded(child: child),
            ]),
          ),
        ),
      );
}
