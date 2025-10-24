import 'package:flutter/material.dart';
import 'package:gymvision/static_data/enums.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;
  List<Category> _historyCategoryFilters = [];

  GlobalKey<NavigatorState> get navKey => _navKey;
  int get selectedIndex => _selectedIndex;
  List<Category> get historyCategoryFilters => _historyCategoryFilters;

  BuildContext? getGlobalContext() => _navKey.currentContext;

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void reloadCurrentTab() {
    notifyListeners();
  }

  void goToHistoryTab({List<Category>? withCategories}) {
    if (withCategories != null) _historyCategoryFilters = withCategories;
    changeTab(1);
  }

  void resetHistoryCategoryFilters() => _historyCategoryFilters = [];
}
