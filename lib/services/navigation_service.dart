import 'package:flutter/material.dart';

class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
  static GlobalKey<NavigatorState> nestedNavKey = GlobalKey();
  static GlobalKey<NavigatorState> groupLeftHalfNavKey = GlobalKey();
  static GlobalKey<NavigatorState> groupRightHalfNavKey = GlobalKey();
}
