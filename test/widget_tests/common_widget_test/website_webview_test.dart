import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/website_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget websiteScreen}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return websiteScreen;
    }));
  }

  /// Functional test cases for Website Screen widget
  group('Website Screen Widget Tests:', () {
    const websiteScreen = WebsiteScreen(
      title: 'Redirect',
      url: 'url',
    );
    // Test Case to Check Website Screen is displayed
    testWidgets("Website Screen is displayed",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(websiteScreen: websiteScreen));
      expect(find.byType(WebsiteScreen), findsOneWidget);
    });

    // Test case to check text is given
    testWidgets("Website Screen text is given",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(websiteScreen: websiteScreen));
      expect(websiteScreen.title, 'Redirect');
    });
      // Test case to check url is given
    testWidgets("Website Screen text is given",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(websiteScreen: websiteScreen));
      expect(websiteScreen.url, 'url');
    });
  });
}
