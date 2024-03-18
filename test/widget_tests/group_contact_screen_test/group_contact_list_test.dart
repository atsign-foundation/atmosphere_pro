import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget contactListTile}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
        body: ListView(
          children: [
            contactListTile,
          ],
        ),
      );
    }));
  }

  /// Functional test cases for Contact List Tile widget
  group('Contact List Tile Widget Tests:', () {
    final contactListTile = ContactListTile(onAdd: () {}, onRemove: () {},name: 'Bluebellrelated86',atSign: '@bluebellrelated86',image: ContactInitial(initials: 'B'),onTileTap: (){},);
    // Test Case to Check Contact List Tile is displayed
    testWidgets("Contact List Tile is displayed", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(find.byType(ContactListTile), findsOneWidget);
    });

    // Test case to check Contact List Tile name is given
    testWidgets("Contact List Tile name is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(find.text('Bluebellrelated86'), findsOneWidget);
    });
    // Test case to check Contact List Tile atsign is given
    testWidgets("Contact List Tile atsign is given", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(find.text('@bluebellrelated86'), findsOneWidget);
    });
      // Test case to check Contact List Tile on Add is given and action
    testWidgets("Contact List Tile on add is given and action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(contactListTile.onAdd.call(),null);
    });

       // Test case to check Contact List Tile on remove is given and action
    testWidgets("Contact List Tile on remove is given and action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(contactListTile.onRemove.call(),null);
    });
         // Test case to check Contact List Tile on tile tap is given and action
    testWidgets("Contact List Tile on tile tap is given and action", (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(contactListTile: contactListTile));
      expect(contactListTile.onTileTap!.call(),null);
    });
  });
}
