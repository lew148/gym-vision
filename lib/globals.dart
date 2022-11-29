String appVersion = 'V 1.0.0.12';

getNumberStringOrDefault(String value) => value == '' ? '0' : value;

bool isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.day == now.day && dt.month == now.month && dt.year == now.year;
}

bool areSameDay(DateTime dt1, DateTime dt2) =>
    dt1.day == dt2.day && dt1.month == dt2.month && dt1.year == dt2.year;
