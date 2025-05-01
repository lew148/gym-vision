import 'dart:math';

import 'package:gymvision/classes/flavour_text.dart';
import 'package:gymvision/static_data/data/flavour_texts.dart';

class FlavourTextModel {
  static FlavourText getRandomFlavourText(List<int> excludedFlavourTextIds) {
    var availablefts = flavourTexts.where((ft) => !excludedFlavourTextIds.contains(ft.id)).toList();
    if (availablefts.isEmpty) {
      availablefts = flavourTexts.toList();
    }

    return availablefts[Random().nextInt(availablefts.length - 1)];
  }
}
