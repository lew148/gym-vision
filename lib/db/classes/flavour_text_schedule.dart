import 'package:gymvision/db/classes/flavour_text.dart';

class FlavourTextSchedule {
  int? id;
  int flavourTextId;
  DateTime date;
  bool dismissed;

  FlavourText? flavourText;

  FlavourTextSchedule({
    this.id,
    required this.flavourTextId,
    required this.date,
    required this.dismissed,
    this.flavourText,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'flavourTextId': flavourTextId,
        'date': date.toString(),
        'dismissed': dismissed ? 1 : 0,
      };
}
