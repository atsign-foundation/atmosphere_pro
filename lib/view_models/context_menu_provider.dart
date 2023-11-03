import 'package:flutter/material.dart';

class ContextMenuProvider extends ChangeNotifier {
  Map<String, bool> listCardState = {};
  Map<String, List<bool>> listItemState = {};
  bool isIgnore = false;

  void reset() {
    listCardState.clear();
    listItemState.clear();
  }

  void resetItemListSelected(String key) {
    if ((listItemState[key] ?? []).isNotEmpty) {
      listItemState[key]!.clear();
    }
  }

  void setIsCardSelected({
    required String key,
    required bool state,
  }) {
    listCardState[key] = state;
    notifyListeners();
  }

  void setIsItemSelected({
    required String key,
    required bool state,
    required int index,
  }) {
    if (listItemState[key] != null) {
      listItemState[key]![index] = state;
    }
    notifyListeners();
  }

  void setIsIgnore(bool state) {
    isIgnore = state;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
