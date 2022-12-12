import 'package:intl/intl.dart';

String appVersion = 'V 1.0.0.14';

getNumberStringOrDefault(String value) => value == '' ? '0' : value;

bool isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.day == now.day && dt.month == now.month && dt.year == now.year;
}

bool areSameDay(DateTime dt1, DateTime dt2) => dt1.day == dt2.day && dt1.month == dt2.month && dt1.year == dt2.year;

String getDatePrefix(DateTime dt) {
  if (dt.day == 1 || dt.day == 21 || dt.day == 31) return 'st';
  if (dt.day == 2 || dt.day == 22) return 'nd';
  if (dt.day == 3 || dt.day == 23) return 'rd';
  return 'th';
}

String getDateNumString(DateTime dt) {
  final today = DateTime.now();
  final prefix = getDatePrefix(dt);

  final String dmyFormat = 'd\'$prefix\' MMM yyyy';
  final String dmFormat = 'd\'$prefix\' MMM';
  final String dFormat = 'd\'$prefix\'';

  if (dt.year != today.year) {
    return DateFormat(dmyFormat).format(dt);
  }

  if (dt.month != today.month) {
    return DateFormat(dmFormat).format(dt);
  }

  return DateFormat(dFormat).format(dt);
}

String getDay(DateTime dt) => DateFormat('EEEE').format(dt);

String getMonthAndYear(DateTime dt) {
  var rn = DateTime.now();
  return  DateFormat(dt.year == rn.year ? 'MMMM' : 'MMMM yyyy').format(dt);
}

String? getYesterdayTodayOrTomorrow(DateTime dt) {
  // if yesterday is last month (eg. today is 1st dec & yesterday is 30th nov) will not be counted as yesterday

  final today = DateTime.now();

  if (areSameDay(today, dt)) {
    return 'Today';
  }

  if (dt.day == today.day + 1 && (dt.month == today.month) && dt.year == today.year) {
    return 'Tomorrow';
  }

  if (dt.day == today.day - 1 && dt.month == today.month && dt.year == today.year) {
    return 'Yesterday';
  }

  return null;
}

int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
