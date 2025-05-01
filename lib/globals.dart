import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

const String appVersion = '1.0.2+37';

const String dmyFormat = 'd MMMM yyyy';
const String dmFormat = 'd MMMM';

String getNumberString(String value) => value == '' ? '0' : value;

String truncateDouble(double? d) {
  if (d == null) return '0';
  return d % 1 == 0 ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

bool isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.day == now.day && dt.month == now.month && dt.year == now.year;
}

String getMonthOrDayString(int num) => num < 10 ? '0$num' : num.toString();

String getMonthAndYear(DateTime dt) => DateFormat(dt.year == DateTime.now().year ? 'MMMM' : 'MMMM yyyy').format(dt);
int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
bool dateIsInFuture(DateTime dt) => DateTime.now().compareTo(dt) < 0;
bool dateXIsAfterDateY(DateTime x, DateTime y) => y.compareTo(x) < 0;

Duration? tryParseDuration(String? s) {
  // format = ##:##:##.######

  if (s == null || s == '') return null;

  try {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    final parts = s.split(':');
    final secondsParts = parts[2].split('.');
    hours = int.parse(parts[0]);
    minutes = int.parse(parts[1]);
    seconds = int.parse(secondsParts[0]);

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  } catch (e) {
    return null;
  }
}

List<int> distinctIntList(Iterable<int> i) => i.toSet().toList();

Widget dashIcon() => const Center(
      child: Text(
        '-',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

String? enumToString(Enum e) {
  try {
    return e.toString().split('.').last;
  } catch (e) {
    return null;
  }
}

T? stringToEnum<T extends Enum>(String str, List<T> enumValues) {
  try {
    return enumValues.firstWhereOrNull((e) => enumToString(e)?.toLowerCase() == str.toLowerCase());
  } catch (e) {
    return null;
  }
}

DateTime parseDateTime(String s) => DateTime.parse(s);

DateTime? tryParseDateTime(String? s) {
  if (s == null || s == '' || s == 'null') return null;
  return DateTime.tryParse(s);
}
