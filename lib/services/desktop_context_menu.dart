import 'package:flutter/material.dart';

class DesktopContextMenu {
  static OverlayEntry? contextMenu;

  static void setContextMenu(Widget widget) {
    contextMenu = OverlayEntry(
      builder: (context) {
        return widget;
      },
    );
  }

  static void show(BuildContext context) {
    if (contextMenu != null) {
      Overlay.of(context).insert(contextMenu!);
    }
  }

  static void hide() {
    if (contextMenu != null) {
      contextMenu!.remove();
    }
  }
}
