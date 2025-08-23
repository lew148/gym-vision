import 'package:collection/collection.dart';

class EnumHelper {
  static String? enumToString(Enum e) {
    try {
      return e.toString().split('.').last;
    } catch (e) {
      return null;
    }
  }

  static T? stringToEnum<T extends Enum>(String str, List<T> enumValues) {
    try {
      return enumValues.firstWhereOrNull((e) => enumToString(e)?.toLowerCase() == str.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
