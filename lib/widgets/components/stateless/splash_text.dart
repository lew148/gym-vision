import 'package:flutter/material.dart';

class SplashText extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;

  const SplashText({
    super.key,
    this.icon,
    required this.title,
    this.description,
  });

  factory SplashText.notFound({String? item, String? description}) => SplashText(
        icon: Icons.question_mark_rounded,
        title: 'This ${item == null ? '' : '$item '}could not be found...',
        description: description ?? 'Please try again',
      );

  factory SplashText.none({String? item, String? description}) => SplashText(
        icon: Icons.inbox_rounded,
        title: 'No ${item == null ? '' : '$item '}yet',
        description: description ?? 'Tap + to get started',
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 60, color: Theme.of(context).colorScheme.secondary),
                  const Padding(padding: EdgeInsetsGeometry.all(10)),
                ],
                Text(
                  title,
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
