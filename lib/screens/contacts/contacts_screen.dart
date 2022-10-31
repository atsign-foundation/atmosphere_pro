import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showLeadingicon: true,
          title: 'Contacts',
          showTitle: true,
          showTrailingButton: true,
          trailingIcon: Icons.add_circle_outline_sharp,
          isContactScreen: true,
          numberOfContacts: 3,
        ),
      ),
    );
  }
}
