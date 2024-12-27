import 'package:gymvision/globals.dart';
import 'package:intl/intl.dart';

class Bodyweight {
  int? id;
  DateTime date;
  double weight;
  String units;

  Bodyweight({
    this.id,
    required this.date,
    required this.weight,
    required this.units,
  });

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toString(), 'weight': weight, 'units': units};

  String getTimeString() => DateFormat('Hm').format(date);

  String getWeightDisplay() => '${truncateDouble(weight)} $units';
}
