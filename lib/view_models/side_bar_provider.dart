import 'package:flutter/material.dart';

class SideBarProvider extends ChangeNotifier {
  bool isSidebarExpanded = true;

  updateSidebarWidth() {
    isSidebarExpanded = !isSidebarExpanded;
    notifyListeners();
  }
}
