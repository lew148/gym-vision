/*
  for ordering strings, following "int1,int2,int3..." format
*/
import 'package:collection/collection.dart';
import 'package:gymvision/classes/db/_dbo.dart';

class OrderingHelper {
  static List<int> getOrderingIntList(String ordering) =>
      ordering.split(',').map((e) => int.tryParse(e)).whereType<int>().toList();

  static String getStringFromIntList(List<int> l) => l.join(',');

  static String addToOrdering(String ordering, int i) {
    var il = getOrderingIntList(ordering);
    if (!il.contains(i)) il.add(i);
    return getStringFromIntList(il);
  }

  static String removeFromOrdering(String ordering, int i) {
    var il = getOrderingIntList(ordering);
    if (!il.contains(i)) return ordering;

    il.remove(i);
    return getStringFromIntList(il);
  }

  static String reorderById(String ordering, int id, int newIndex) {
    var il = getOrderingIntList(ordering);
    if (il.isEmpty || !il.contains(id)) return ordering;

    final index = il.indexOf(id);
    il.removeAt(index);
    il.insert(newIndex, id);
    return getStringFromIntList(il);
  }

  static String reorderByIndex(String ordering, int currentIndex, int newIndex) {
    var il = getOrderingIntList(ordering);
    if (il.isEmpty || currentIndex > il.length - 1) return ordering;

    final id = il[currentIndex];
    il.removeAt(currentIndex);
    il.insert(newIndex, id);
    return getStringFromIntList(il);
  }

  static List<T> orderListById<T extends DBO>(List<T> list, String ordering) {
    final List<T> newOrder = [];
    final List<T> remainders = [...list];

    for (var i in getOrderingIntList(ordering)) {
      var match = remainders.firstWhereOrNull((x) => x.id == i);
      if (match == null) continue;
      newOrder.add(match);
      remainders.removeWhere((x) => x.id == i);
    }

    newOrder.addAll(remainders);
    return newOrder;
  }
}
