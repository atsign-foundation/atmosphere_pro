import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/information_card_expanded.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/circular_icon.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/desktop_contact_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_card_widget.dart';
import 'package:flutter/material.dart';

class DesktopContactsScreen extends StatefulWidget {
  const DesktopContactsScreen({Key? key}) : super(key: key);

  @override
  State<DesktopContactsScreen> createState() => _DesktopContactsScreenState();
}

class _DesktopContactsScreenState extends State<DesktopContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Row(
        children: [
          Container(
            color: Color(0xFFF8F8F8),
            padding:
                const EdgeInsets.only(left: 50.0, top: 35, right: 50, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(),
                Divider(
                  height: 35,
                  color: Colors.black,
                ),
                // Expanded(
                // child:
                // Text('test')
                Container(
                  width: double.infinity,
                  child: DesktopContactCard(
                    contact: AtContact(atSign: '@kevin'),
                  ),
                ),
                // )
              ],
            ),
          ),
InformationCardExpanded(atContact: atContact, onBack: onBack)
        ],
      ),
    );
  }
}

Widget Header() {
  return Row(
    children: [
      Text(
        'Contacts',
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      Spacer(),
      CircularIcon(icon: Icons.search),
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: CircularIcon(icon: Icons.check),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: CircularIcon(icon: Icons.refresh),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: CommonButton(
          'Add contact',
          () {
            // showDialog(
            //   context: context,
            //   builder: (context) => const AddContactDialog(),
            // );
          },
          color: Color(0xFFF07C50),
          border: 20,
          height: 40,
          width: 136,
          fontSize: 18,
          removePadding: true,
        ),
      )
    ],
  );
}
