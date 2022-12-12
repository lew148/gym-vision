import 'package:flutter/material.dart';

Widget getSectionTitle(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.shadow,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

Widget getPrimaryButton(IconData icon, Function() onPressed) => OutlinedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 25,
        ),
      ),
    );

Widget getSectionTitleWithAction(BuildContext context, String title, IconData actionIcon, Function() actionOnPressed) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        getSectionTitle(context, title),
        getPrimaryButton(actionIcon, actionOnPressed),
      ],
    );
