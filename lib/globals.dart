import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

const String appVersion = '1.0.6';

const String dmyFormat = 'd MMMM yyyy';
const String dmFormat = 'd MMMM';
const dayFormat = 'EEEE';

const propOnCardColor = Color.fromARGB(255, 60, 60, 60);

const dayStrings = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String getDateStr(DateTime dt) =>
    dt.year != DateTime.now().year ? DateFormat(dmyFormat).format(dt) : DateFormat(dmFormat).format(dt);

String getDateOrDayStr(DateTime dt) {
  final now = DateTime.now();
  if (isToday(dt, now: now)) return 'Today';
  if (isTomorrow(dt, now: now)) return 'Tomorrow';
  if (isYesterday(dt, now: now)) return 'Yesterday';
  return getDateStr(dt);
}

String getNumberString(String value) => value == '' ? '0' : value;

String truncateDouble(double? d) {
  if (d == null) return '0';
  return d % 1 == 0 ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

bool isToday(DateTime dt, {DateTime? now}) {
  now ??= DateTime.now();
  return dt.day == now.day && dt.month == now.month && dt.year == now.year;
}

bool isTomorrow(DateTime dt, {DateTime? now}) {
  now ??= DateTime.now();
  return dt.day == now.day + 1 && dt.month == now.month && dt.year == now.year;
}

bool isYesterday(DateTime dt, {DateTime? now}) {
  now ??= DateTime.now();
  return dt.day == now.day - 1 && dt.month == now.month && dt.year == now.year;
}

String getMonthOrDayString(int num) => num < 10 ? '0$num' : num.toString();

String getMonthAndYear(DateTime dt) => DateFormat(dt.year == DateTime.now().year ? 'MMMM' : 'MMMM yyyy').format(dt);
int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
bool dateIsInFuture(DateTime dt) => DateTime.now().compareTo(dt) < 0;
bool dateXIsAfterDateY(DateTime x, DateTime y) => y.compareTo(x) < 0;

String getIntTwoDigitsString(int n) => n.toString().padLeft(2, "0");

String getDurationString(Duration duration) {
  String hours = getIntTwoDigitsString(duration.inHours);
  String minutes = getIntTwoDigitsString(duration.inMinutes.remainder(60).abs());
  String seconds = getIntTwoDigitsString(duration.inSeconds.remainder(60).abs());
  return "${duration.isNegative ? '-' : ''}$hours:$minutes:$seconds";
}

String getHoursAndMinsDurationString(Duration duration) {
  String gap = '';
  String hours = duration.inHours == 0 ? '' : '${duration.inHours}h';
  String minutes = duration.inMinutes == 0 ? '' : '${duration.inMinutes.remainder(60).abs()}m';
  if (hours != '' && minutes != '') gap = ' ';
  if (hours == '' && minutes == '') minutes = '<1m';
  return "$hours$gap$minutes";
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return to.difference(from).inDays;
}

Duration timeBetween(DateTime from, DateTime to) => to.difference(from);

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

double? stringToDouble(String s) => double.tryParse(getNumberString(s).replaceAll(',', '.'));
