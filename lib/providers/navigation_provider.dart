import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  GlobalKey<NavigatorState> get navKey => _navKey;

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void reloadCurrentTab() {
    notifyListeners();
  }

  BuildContext? getGlobalContext() => _navKey.currentContext;
}
