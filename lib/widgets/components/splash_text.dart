import 'package:flutter/material.dart';

class SplashText extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? description;

  const SplashText({
    super.key,
    this.icon,
    required this.title,
    this.description,
  });

  @override
  State<SplashText> createState() => _SplashTextState();

  static SplashText notFound({String? item}) => SplashText(
        title: 'This ${item == null ? '' : '$item '}could not be found',
        icon: Icons.question_mark_rounded,
      );
}

class _SplashTextState extends State<SplashText> {
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
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 60, color: Theme.of(context).colorScheme.primary),
                const Padding(padding: EdgeInsetsGeometry.all(10)),
              ],
              Text(
                widget.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              if (widget.description != null)
                Text(
                  widget.description!,
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
