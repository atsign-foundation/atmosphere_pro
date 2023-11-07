import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_backup_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget sideBarBackupItem}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(drawer: sideBarBackupItem);
    }));
  }

  /// Functional test cases for Side bar backup item widget
  group('Side bar backup item Widget Tests:', () {
    final sideBarBackupItem = SideBarBackupItem(
      title: 'SideBar',
      leadingIcon: const Icon(Icons.menu),
      onPressed: () {
        print('Sidebar displayed');
      },
    );
    // Test case to check text is given
    testWidgets("Side bar backup item text is given",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(sideBarBackupItem: sideBarBackupItem));
      expect(sideBarBackupItem.title, 'SideBar');
    });
  });
}
