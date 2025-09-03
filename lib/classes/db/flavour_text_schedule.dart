import 'package:collection/collection.dart';
import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/classes/flavour_text.dart';
import 'package:gymvision/static_data/data/flavour_texts.dart';

class FlavourTextSchedule extends DBO {
  int flavourTextId;
  DateTime date;
  bool dismissed;

  FlavourTextSchedule({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.flavourTextId,
    required this.date,
    required this.dismissed,
  });

  FlavourText? getFlavourText() => flavourTexts.firstWhereOrNull((ft) => ft.id == flavourTextId);
}
