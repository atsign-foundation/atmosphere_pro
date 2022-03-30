import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget commonButton}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
          body: Column(
        children: [
          commonButton,
        ],
      ));
    }));
  }

  /// Functional test cases for Common button widget
  group('Commom button Widget Tests:', () {
    final commonButton = CommonButton('Click', () {
      print('Onpress is given an action');
    });
    // Test Case to Check common button is displayed
    testWidgets("Common button is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(commonButton: commonButton));
      expect(find.byType(CommonButton), findsOneWidget);
    });

    // Test case to check buttom text is given
    testWidgets("Common button text is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(commonButton: commonButton));
      expect(find.text('Click'), findsOneWidget);
    });

     // Test case to check onPress functionality
    testWidgets("OnPress is given an action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(commonButton: commonButton));
      expect(commonButton.onTap!.call(), null);
    });
  });
}
