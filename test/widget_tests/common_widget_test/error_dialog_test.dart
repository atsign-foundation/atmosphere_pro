import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget errorDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
          body: Column(
        children: [
          errorDialog,
        ],
      ));
    }));
  }

  /// Functional test cases for Error Dialog widget
  group('Error dialog Widget Tests:', () {
    final errorDialog = ErrorDialogWidget(
      text: 'Error',
      buttonText: 'Ok',
      onButtonPress: () {
        print('Error Displayed');
      },
      includeCancel: true,
    );
    // Test Case to Check Error dialog is displayed
    testWidgets("Error dialog is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(errorDialog: errorDialog));
      expect(find.byType(ErrorDialogWidget), findsOneWidget);
    });

    // Test case to check text is given
    testWidgets("Error dialog text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(errorDialog: errorDialog));
      expect(errorDialog.text, 'Error');
    });

    // Test case to check button text is given
    testWidgets("Error dialog text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(errorDialog: errorDialog));
      expect(errorDialog.buttonText, 'Ok');
    });

    // Test case to check onPress functionality
    testWidgets("OnPress is given an action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(errorDialog: errorDialog));
      expect(errorDialog.onButtonPress!.call(), null);
    });
  });
}
