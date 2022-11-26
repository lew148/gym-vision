import 'category.dart';

class Exercise {
  int? id;
  final int categoryId;
  String name;
  double weight;
  double? max;
  int reps;
  bool isSingle;

  Category? category;

  Exercise({
    this.id,
    required this.categoryId,
    required this.name,
    required this.weight,
    required this.max,
    required this.reps,
    required this.isSingle,
    this.category,
  });

  String getWeightAsString() =>
      weight % 1 == 0 ? weight.toStringAsFixed(0) : weight.toStringAsFixed(2);

  String getWeightString({bool showNone = true}) {
    if (weight == 0) return showNone ? 'None' : '';
    return '${getWeightAsString()}kg';
  }

  String getNumberedWeightString({bool showNone = true}) {
    if (weight == 0) return showNone ? 'None' : '';
    return '${isSingle ? '' : '2 x '}${getWeightString(showNone: showNone)}';
  }

  bool hasWeight() => weight != 0;

  String getMaxAsString() {
    if (max == null) return '0';
    return max! % 1 == 0 ? max!.toStringAsFixed(0) : max!.toStringAsFixed(2);
  }

  String getMaxString() =>
      max == null || max == 0 ? 'None' : '${getMaxAsString()}kg';

  String getRepsString() => reps <= 0 ? 'None' : reps.toString();

  bool singleRep() => reps == 1;

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'weight': weight,
        'max': max,
        'reps': reps,
        'isSingle': isSingle,
      };
}
