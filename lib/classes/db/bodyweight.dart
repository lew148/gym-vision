import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:intl/intl.dart';

class Bodyweight extends DatabaseObject {
  DateTime date;
  double weight;
  String units;

  Bodyweight({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.date,
    required this.weight,
    required this.units,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'date': date.toString(),
        'weight': weight,
        'units': units,
      };

  String getTimeString() => DateFormat('Hm').format(date);
  String getWeightDisplay() => '${NumberHelper.truncateDouble(weight)}$units';
}
