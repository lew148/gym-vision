import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/flavour_text.dart';
import 'package:gymvision/db/helpers/flavour_text_helper.dart';

class FlavourTextCard extends StatefulWidget {
  const FlavourTextCard({super.key});

  @override
  State<StatefulWidget> createState() => _FlavourTextCardState();
}

class _FlavourTextCardState extends State<FlavourTextCard> {
  final Future<FlavourText> flavourText =
      FlavourTextHelper().getRandomFlavourText();
  var isHidden = false;

  @override
  Widget build(BuildContext context) {
    return isHidden
        ? const SizedBox.shrink()
        : FutureBuilder<FlavourText>(
            future: flavourText,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              snapshot.data!.message,
                              style: const TextStyle(
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
            },
          );
  }
}
