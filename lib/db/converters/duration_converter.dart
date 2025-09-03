import 'package:drift/drift.dart';
import 'package:gymvision/helpers/datetime_helper.dart';

class DurationConverter extends TypeConverter<Duration?, String?> {
  const DurationConverter();

  @override
  Duration? fromSql(String? s) => s == null || s == 'null' ? null : DateTimeHelper.tryParseDuration(s);

  @override
  String toSql(Duration? duration) => duration.toString();
}
