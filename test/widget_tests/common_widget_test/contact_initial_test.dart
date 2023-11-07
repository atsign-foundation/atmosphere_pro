import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget confirmationDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
          body: Column(
        children: [
          confirmationDialog,
        ],
      ));
    }));
  }

  /// Functional test cases for Contact Initial widget
  group('Contact Initial Widget Tests:', () {
    const confirmationDialog = ContactInitial(initials: 'A',background: Colors.orange,);
    // Test Case to Check Contact Initial is displayed
    testWidgets("Contact Initial is displayed", (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(find.byType(ContactInitial), findsOneWidget);
    });

    // Test case to check Contact Initial text is given
    testWidgets("Contact Initial text is given", (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(find.text('A'), findsOneWidget);
    });

     // Test case to check Contact Initial background is given
    testWidgets("Contact Initial background is given", (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(confirmationDialog.background,Colors.orange);
    });
  });
}
