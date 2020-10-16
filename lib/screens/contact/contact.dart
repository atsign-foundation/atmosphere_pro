import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ContactProvider provider;
  String searchText;

  @override
  void initState() {
    provider = ContactProvider();
    provider.getContacts();
    // contacts.sort();
    searchText = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactProvider>(create: (context) => provider)
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          showAddButton: true,
          showTitle: true,
          title: TextStrings().sidebarContact,
          onActionpressed: (String atSignName) =>
              provider.addContact(atSign: atSignName),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 16.toWidth, vertical: 16.toHeight),
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
                ProviderHandler<ContactProvider>(
                    functionName: provider.Contacts,
                    errorBuilder: (provider) => Center(
                          child: Text('Some error occured'),
                        ),
                    successBuilder: (provider) {
                      return (provider.contactList.isEmpty)
                          ? Center(
                              child: Text('No Contact found'),
                            )
                          : ListView.builder(
                              itemCount: 26,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, alphabetIndes) {
                                List<String> _filteredList = [];
                                provider.contactList.forEach((c) {
                                  if (c.atSign[1]
                                      .toUpperCase()
                                      .contains(searchText.toUpperCase())) {
                                    _filteredList.add(c.atSign);
                                  }
                                });

                                String currentChar =
                                    String.fromCharCode(alphabetIndes + 65)
                                        .toUpperCase();
                                List<String> contactsForAlphabet = [];

                                _filteredList.forEach((c) {
                                  if (c[1].toUpperCase() == currentChar) {
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
                                              color: ColorConstants.dividerColor
                                                  .withOpacity(0.2),
                                              height: 1.toHeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ListView.separated(
                                          itemCount: contactsForAlphabet.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          separatorBuilder: (context, _) =>
                                              Divider(
                                                color: ColorConstants
                                                    .dividerColor
                                                    .withOpacity(0.2),
                                                height: 1.toHeight,
                                              ),
                                          itemBuilder: (context, index) {
                                            var contactuser =
                                                provider.contactList[index];
                                            return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Slidable(
                                                  actionPane:
                                                      SlidableDrawerActionPane(),
                                                  actionExtentRatio: 0.25,
                                                  secondaryActions: <Widget>[
                                                    IconSlideAction(
                                                      caption: 'Block',
                                                      color: ColorConstants
                                                          .inputFieldColor,
                                                      icon: Icons.block,
                                                      onTap: () {
                                                        print('Block');
                                                        provider
                                                            .blockUnBLockContact(
                                                                atSign:
                                                                    contactuser
                                                                        .atSign,
                                                                blockAction:
                                                                    true);
                                                      },
                                                    ),
                                                    IconSlideAction(
                                                      caption: 'Delete',
                                                      color: Colors.red,
                                                      icon: Icons.delete,
                                                      onTap: () {
                                                        provider
                                                            .deleteAtsignContact(
                                                                atSign:
                                                                    contactuser
                                                                        .atSign);
                                                      },
                                                    ),
                                                  ],
                                                  child: Container(
                                                    child: ListTile(
                                                      title: Text(
                                                        contactsForAlphabet[
                                                                index]
                                                            .substring(1),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.toFont,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        contactsForAlphabet[
                                                            index],
                                                        style: TextStyle(
                                                          color: ColorConstants
                                                              .fadedText,
                                                          fontSize: 14.toFont,
                                                        ),
                                                      ),
                                                      leading: Container(
                                                          height: 40.toWidth,
                                                          width: 40.toWidth,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child:
                                                              CustomCircleAvatar(
                                                            image:
                                                                ImageConstants
                                                                    .colin,
                                                          )),
                                                      trailing: IconButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                          Routes.WELCOME_SCREEN,
                                                        ),
                                                        icon: Image.asset(
                                                          ImageConstants
                                                              .sendIcon,
                                                          width: 21.toWidth,
                                                          height: 18.toHeight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                          }),
                                    ],
                                  ),
                                );
                              },
                            );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
