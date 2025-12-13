import 'package:flutter/material.dart';
import 'package:gymvision/classes/set_info.dart';

class SetInfoWidget extends StatelessWidget {
  final SetInfo? info;
  final bool small;

  const SetInfoWidget({
    super.key,
    required this.info,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    if (info == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (info?.isPRMatch ?? false)
          Icon(
            info?.isPR ?? false ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: small ? 16 : null,
          ),
        if (info?.isFirstUse ?? false)
          Icon(
            Icons.fiber_new_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: small ? 16 : null,
          ),
      ],
    );
  }
}
