import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ContactProvider provider;
  final List<String> contacts = [
    'A1',
    'A2',
    'B1',
    'C4',
    'F6',
    'B5',
    'B8',
    'F9',
    'G1',
    'H7',
    'C6',
  ];
  String searchText;

  @override
  void initState() {
    provider = ContactProvider();
    provider.getContacts();
    contacts.sort();
    searchText = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBarWithCloseButton(
      //   title: TextStrings().sidebarContact,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.add),
      //       onPressed: () {
      //         Navigator.of(context).pushNamed(
      //           Routes.ADD_CONTACT_SCREEN,
      //         );
      //       },
      //     ),
      //   ],
      // ),
      appBar: CustomAppBar(
        showAddButton: true,
        showTitle: true,
        title: TextStrings().sidebarContact,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.toWidth, vertical: 16.toHeight),
          child: Column(
            children: [
              ContactSearchField(
                TextStrings().searchContact,
                (text) => setState(() {
                  searchText = text;
                }),
              ),
              SizedBox(
                height: 15.toHeight,
              ),
              ListView.builder(
                itemCount: 26,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, alphabetIndes) {
                  List<String> _filteredList = [];
                  contacts.forEach((c) {
                    if (c.toUpperCase().contains(searchText.toUpperCase())) {
                      _filteredList.add(c);
                    }
                  });

                  String currentChar = String.fromCharCode(alphabetIndes + 65).toUpperCase();
                  List<String> contactsForAlphabet = [];

                  _filteredList.forEach((c) {
                    if (c.toUpperCase().startsWith(currentChar)) {
                      contactsForAlphabet.add(c);
                    }
                  });

                  if (contactsForAlphabet.isEmpty) {
                    return Container();
                  }

                  return Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              currentChar,
                              style: TextStyle(
                                color: ColorConstants.blueText,
                                fontSize: 16.toFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.toWidth),
                            Expanded(
                              child: Divider(
                                color: ColorConstants.dividerColor.withOpacity(0.2),
                                height: 1.toHeight,
                              ),
                            ),
                          ],
                        ),
                        ProviderHandler<ContactProvider>(
                          functionName: provider.Contacts,
                          successBuilder: (provider) => (provider.contacts.isEmpty)
                              ? Center(
                                  child: Text('No files sent'),
                                )
                              : ListView.separated(
                                  itemCount: contactsForAlphabet.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  separatorBuilder: (context, _) => Divider(
                                        color: ColorConstants.dividerColor.withOpacity(0.2),
                                        height: 1.toHeight,
                                      ),
                                  itemBuilder: (context, index) {
                                    var contactuser = provider.contacts[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: ListTile(
                                          title: Text(
                                            contactsForAlphabet[index],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.toFont,
                                            ),
                                          ),
                                          subtitle: Text(
                                            contactuser['name'].toString(),
                                            style: TextStyle(
                                              color: ColorConstants.fadedText,
                                              fontSize: 14.toFont,
                                            ),
                                          ),
                                          leading: Container(
                                            height: 40.toWidth,
                                            width: 40.toWidth,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            onPressed: () => Navigator.of(context).pushNamed(
                                              Routes.WELCOME_SCREEN,
                                            ),
                                            icon: Image.asset(
                                              ImageConstants.sendIcon,
                                              width: 21.toWidth,
                                              height: 18.toHeight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                          errorBuilder: (provider) => Center(
                            child: Text('Some error occured'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
