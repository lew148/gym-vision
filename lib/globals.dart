import 'package:intl/intl.dart';

String appVersion = 'V 1.0.0.16';

getNumberStringOrDefault(String value) => value == '' ? '0' : value;

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

String getDateNumString(DateTime dt) => DateFormat('d').format(dt);

String getMonthAndYear(DateTime dt) => DateFormat(dt.year == DateTime.now().year ? 'MMMM' : 'MMMM yyyy').format(dt);

int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

bool dateIsInFuture(DateTime dt) => DateTime.now().compareTo(dt) < 0;
