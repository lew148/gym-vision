import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  GlobalKey<NavigatorState> get navKey => _navKey;
  int get selectedIndex => _selectedIndex;

  BuildContext? getGlobalContext() => _navKey.currentContext;

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void reloadCurrentTab() {
    notifyListeners();
  }
}
