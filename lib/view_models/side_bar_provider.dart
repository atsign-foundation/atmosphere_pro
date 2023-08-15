import 'package:flutter/material.dart';

class SideBarProvider extends ChangeNotifier {
  bool isSidebarExpanded = true;
  bool isSwitchingAtSign = false;

  updateSidebarWidth() {
    isSidebarExpanded = !isSidebarExpanded;
    if (!isSidebarExpanded && isSwitchingAtSign) {
      changeIsSwitchingAtSign();
    }
    notifyListeners();
  }

  void changeIsSwitchingAtSign() {
    isSwitchingAtSign = !isSwitchingAtSign;
    if (isSwitchingAtSign && !isSidebarExpanded) {
      updateSidebarWidth();
    }
    notifyListeners();
  }
}
