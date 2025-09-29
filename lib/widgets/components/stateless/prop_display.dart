import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';

enum PropDisplaySize {
  small,
  medium,
  large,
}

class PropDisplay extends StatelessWidget {
  final String text;
  final PropDisplaySize size;
  final Function()? onTap;
  final Color? color;

  const PropDisplay({
    super.key,
    required this.text,
    this.size = PropDisplaySize.medium,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(size == PropDisplaySize.small ? 5 : 10),
          child: onTap == null
              ? Text(text)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(text, style: TextStyle(fontSize: size == PropDisplaySize.large ? 18 : null)),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.shadow,
                      size: size == PropDisplaySize.small ? 15 : null,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
