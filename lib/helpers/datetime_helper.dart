import 'package:gymvision/helpers/number_helper.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static const String dmyFormat = 'd MMMM yyyy';
  static const String dmFormat = 'd MMMM';
  static const String dayFormat = 'EEEE';
  static const String hmFormat = 'Hm';

  static const dayStrings = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static DateTime parseDateTime(String s) => DateTime.parse(s);

  static DateTime roundToDay(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  static String getDateStr(DateTime dt) =>
      dt.year != DateTime.now().year ? DateFormat(dmyFormat).format(dt) : DateFormat(dmFormat).format(dt);

  static String getDateOrDayStr(DateTime dt) {
    final now = DateTime.now();
    if (isToday(dt, now: now)) return 'Today';
    if (isTomorrow(dt, now: now)) return 'Tomorrow';
    if (isYesterday(dt, now: now)) return 'Yesterday';
    return getDateStr(dt);
  }

  static bool isToday(DateTime dt, {DateTime? now}) {
    now ??= DateTime.now();
    return dt.day == now.day && dt.month == now.month && dt.year == now.year;
  }

  static bool isTomorrow(DateTime dt, {DateTime? now}) {
    now ??= DateTime.now();
    return dt.day == now.day + 1 && dt.month == now.month && dt.year == now.year;
  }

  static bool isYesterday(DateTime dt, {DateTime? now}) {
    now ??= DateTime.now();
    return dt.day == now.day - 1 && dt.month == now.month && dt.year == now.year;
  }

  static String getMonthAndYearString(DateTime dt) =>
      DateFormat(dt.year == DateTime.now().year ? 'MMMM' : 'MMMM yyyy').format(dt);

  static int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  static bool isInFuture(DateTime dt) => DateTime.now().compareTo(dt) < 0;

  static bool dateXIsAfterDateY(DateTime x, DateTime y) => y.compareTo(x) < 0;

  static String getDurationString(Duration duration, {bool noHours = false, bool useNegativeSymbol = true}) {
    String hours = noHours ? '' : duration.inHours.abs().toString();
    String minutes = noHours
        ? NumberHelper.getDoubleDigit(duration.inMinutes.abs())
        : NumberHelper.getDoubleDigit(duration.inMinutes.remainder(60).abs());
    String seconds = NumberHelper.getDoubleDigit(duration.inSeconds.remainder(60).abs());
    return "${useNegativeSymbol && duration.isNegative ? '-' : ''}${noHours || duration.inHours == 0 ? '' : '$hours:'}$minutes:$seconds";
  }

  static String getHoursAndMinsDurationString(Duration duration) {
    String gap = '';
    String hours = duration.inHours == 0 ? '' : '${duration.inHours}h';
    String minutes = duration.inMinutes.remainder(60) == 0 ? '' : '${duration.inMinutes.remainder(60).abs()}m';
    if (hours != '' && minutes != '') gap = ' ';
    if (hours == '' && minutes == '') minutes = '<1m';
    return "$hours$gap$minutes";
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  static int hoursBetween(DateTime from, DateTime to) => to.difference(from).inHours;

  static Duration timeBetween(DateTime from, DateTime to) => to.difference(from);

  static Duration? tryParseDuration(String? s) {
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

  static DateTime? tryParseDateTime(String? s) {
    if (s == null || s == '' || s == 'null') return null;
    return DateTime.tryParse(s);
  }
}
