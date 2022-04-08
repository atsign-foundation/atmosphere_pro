import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/add_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget addContact}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return addContact;
    }));
  }

  /// Functional test cases for Add contact widget
  group('Add Contact Widget Tests:', () {
    final addContact = AddContact(
      atSignName: '@bluebellrelated86',
      name: 'Blue bell',
    );
    // Test Case to Check add contact is displayed
    testWidgets("Add Contact is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(addContact: addContact));
      expect(find.byType(AddContact), findsOneWidget);
    });

    // Test case to check add contact atsign is given
    testWidgets("Add contact atsign is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(addContact: addContact));
      expect(find.text('@bluebellrelated86'), findsOneWidget);
    });

    // Test case to check add contact name is given
    testWidgets("Add contact name is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(addContact: addContact));
      expect(find.text('Blue bell'), findsOneWidget);
    });
  });
}
