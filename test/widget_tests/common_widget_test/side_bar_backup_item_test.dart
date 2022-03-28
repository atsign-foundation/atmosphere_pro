import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_backup_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget sideBarBackupItem}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return sideBarBackupItem;
    }));
  }

  /// Functional test cases for Side bar backup item widget
  group('Side bar backup item Widget Tests:', () {
    final sideBarBackupItem = SideBarBackupItem(
      title: 'SideBar',
      leadingIcon: Icon(Icons.menu),
      onPressed: () {
        print('Sidebar displayed');
      },
    );
    // Test Case to Check Side bar backup item is displayed
    testWidgets("Side bar backup item is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(sideBarBackupItem: sideBarBackupItem));
      expect(find.byType(SideBarBackupItem), findsOneWidget);
    });

    // Test case to check text is given
    testWidgets("Side bar backup item text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(sideBarBackupItem: sideBarBackupItem));
      expect(sideBarBackupItem.title, 'SideBar');
    });

    // Test case to leading icon is given
    testWidgets("Side bar backup item text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(sideBarBackupItem: sideBarBackupItem));
      expect(sideBarBackupItem.leadingIcon,Icons.menu);
    });
  });
}
