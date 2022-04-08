import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customButton}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
          body: Column(
        children: [
          customButton,
        ],
      ));
    }));
  }

  /// Functional test cases for Custom button widget
  group('Custom button Widget Tests:', () {
    final customButton = CustomButton(buttonText: 'Click',onPressed:  () {
      print('Onpress is given an action');
    },);
    // Test Case to Check custom button is displayed
    testWidgets("Custom button is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(find.byType(CustomButton), findsOneWidget);
    });

    // Test case to check buttom text is given
    testWidgets("Custom button text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(find.text('Click'), findsOneWidget);
    });

     // Test case to check onPress functionality
    testWidgets("OnPress is given an action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(customButton.onPressed!.call(), null);
    });
  });
}
