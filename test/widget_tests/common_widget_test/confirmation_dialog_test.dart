import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
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

  /// Functional test cases for Confirmation Dialog widget
  group('Confirmation Dialog Widget Tests:', () {
    final confirmationDialog = ConfirmationDialog('Confirm', () {
      print('Conifmation dialog is shown');
    });
    // Test Case to Check Confirmation Dialog is displayed
    testWidgets("Confirmation Dialog is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(find.byType(ConfirmationDialog), findsOneWidget);
    });

    // Test case to check Confirmation Dialog title is given
    testWidgets("Confirmation Dialog text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(find.text('Confirm'), findsOneWidget);
    });

    // Test case to check onPress functionality
    testWidgets("Confirmation dialog is given an action",
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(confirmationDialog: confirmationDialog));
      expect(confirmationDialog.onConfirmation.call(), null);
    });
  });
}
