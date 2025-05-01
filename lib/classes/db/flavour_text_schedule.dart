import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/flavour_text.dart';

class FlavourTextSchedule extends DatabaseObject {
  int flavourTextId;
  DateTime date;
  bool dismissed;

  // non-db props
  FlavourText? flavourText;

  FlavourTextSchedule({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.flavourTextId,
    required this.date,
    required this.dismissed,
    this.flavourText,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'flavourTextId': flavourTextId,
        'date': date.toString(),
        'dismissed': dismissed ? 1 : 0,
      };
}
