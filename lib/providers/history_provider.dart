import 'package:flutter/material.dart';
import 'package:gymvision/static_data/enums.dart';

class HistoryProvider extends ChangeNotifier {
  List<Category> _categoryFilters = [];

  List<Category> get categoryFilters => _categoryFilters;

  void setCategoryFilters(List<Category> categories) {
    _categoryFilters = categories;
    notifyListeners();
  }
}
