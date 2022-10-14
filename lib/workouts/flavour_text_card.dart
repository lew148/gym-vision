import 'package:flutter/material.dart';

class FlavourTextCard extends StatefulWidget {
  const FlavourTextCard({super.key});

  @override
  State<StatefulWidget> createState() => _FlavourTextCardState();
}

class _FlavourTextCardState extends State<FlavourTextCard> {
  var isHidden = false;

  @override
  Widget build(BuildContext context) {
    return isHidden
        ? const SizedBox.shrink()
        : Row(
            children: [
              Expanded(
                child: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // todo: make this randomised
                        const Text(
                          'Make sure you are drinking enough water!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            isHidden = true;
                          }),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
