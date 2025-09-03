class NumberHelper {
  static String getNumberString(String value) => value == '' ? '0' : value;

  static String truncateDouble(double? d) {
    if (d == null) return '0';
    return d % 1 == 0 ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
  }

  static String getDoubleDigit(int n) => n.toString().padLeft(2, "0");

  static List<int> distinctIntList(Iterable<int> i) => i.toSet().toList();

  static double? parseDouble(String s) => double.tryParse(getNumberString(s).replaceAll(',', '.'));
}
