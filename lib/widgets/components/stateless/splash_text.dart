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
        title: 'This ${item == null ? '' : '$item '}could not be found...',
        icon: Icons.question_mark_rounded,
        description: description ?? 'Please try again',
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 60, color: Theme.of(context).colorScheme.primary),
                const Padding(padding: EdgeInsetsGeometry.all(10)),
              ],
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      ],
    );
  }
}
