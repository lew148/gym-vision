import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String appVersion = 'V 1.0.0.35';

String getNumberString(String value) => value == '' ? '0' : value;

String truncateDouble(double? d) {
  if (d == null) return '0';
  return d % 1 == 0 ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

bool isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.day == now.day && dt.month == now.month && dt.year == now.year;
}

String getDatePrefix(DateTime dt) {
  if (dt.day == 1 || dt.day == 21 || dt.day == 31) return 'st';
  if (dt.day == 2 || dt.day == 22) return 'nd';
  if (dt.day == 3 || dt.day == 23) return 'rd';
  return 'th';
}

String getDateString(DateTime dt) {
  final today = DateTime.now();
  final prefix = getDatePrefix(dt);

  final String dmyFormat = 'd\'$prefix\' MMM yyyy';
  final String dmFormat = 'd\'$prefix\' MMM';

  if (dt.year != today.year) {
    return DateFormat(dmyFormat).format(dt);
  }

  return DateFormat(dmFormat).format(dt);
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
