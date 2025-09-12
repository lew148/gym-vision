import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/helpers/number_helper.dart';
import 'package:intl/intl.dart';

class Bodyweight extends DBO {
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

  String getTimeString() => DateFormat('Hm').format(date);
  String getWeightDisplay() => '${NumberHelper.truncateDouble(weight)}$units';
}
