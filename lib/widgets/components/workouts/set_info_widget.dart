import 'package:flutter/material.dart';
import 'package:gymvision/classes/set_info.dart';

class SetInfoWidget extends StatelessWidget {
  final SetInfo? info;
  final bool small;
  final EdgeInsetsGeometry? padding;

  const SetInfoWidget({
    super.key,
    required this.info,
    this.small = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final renderable = info != null && (info!.isFirstUse || info!.isPRMatch);
    if (!renderable) return const SizedBox.shrink();

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (info?.isFirstUse ?? false)
            Icon(
              Icons.fiber_new_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: small ? 16 : null,
            ),
          if (info?.isPRMatch ?? false)
            Icon(
              info?.isPR ?? false ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: small ? 16 : null,
            ),
        ],
      ),
    );
  }
}
