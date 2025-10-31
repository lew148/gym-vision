import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  GlobalKey<NavigatorState> get navKey => _navKey;
  int get selectedIndex => _selectedIndex;

  BuildContext? getGlobalContext() => _navKey.currentContext;

  void toTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toTodayTab() => toTab(0);
  void toHistoryTab() => toTab(1);
  void toExercisesTab() => toTab(2);
  void toProgressTab() => toTab(3);
  void toProfileTab() => toTab(4);

  void reloadCurrentTab() {
    notifyListeners();
  }
}
