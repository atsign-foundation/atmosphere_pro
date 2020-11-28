import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/custom_bottom_sheet.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/circular_contacts.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/limit_alert.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupContactScreen extends StatefulWidget {
  @override
  _GroupContactScreenState createState() => _GroupContactScreenState();
}

class _GroupContactScreenState extends State<GroupContactScreen> {
  // ContactProvider _contactProvider = ContactProvider();
  ContactProvider contactProvider;
  @override
  void initState() {
    contactProvider = Provider.of<ContactProvider>(context, listen: false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    contactProvider = Provider.of<ContactProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showLeadingicon: false,
          showTitle: true,
          title: 'Select Contacts',
        ),
        bottomSheet: Consumer<ContactProvider>(
          builder: (context, provider, _) => (provider.selectedContacts.isEmpty)
              ? Container(
                  height: 0,
                )
              : CustomBottomSheet(
                  numberOfContacts: provider.selectedContacts.length,
                ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Consumer<ContactProvider>(
                builder: (context, provider, _) => LimitAlert(
                  limitReached: provider.limitReached,
                  // onChange: (s) {
                  //   provider.limitReached = s;
                  // },
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Consumer<ContactProvider>(
                      builder: (context, provider, _) => Container(
                        height: 40.toHeight,
                        child: (provider.limitReached)
                            ? Container()
                            : ContactSearchField(
                                TextStrings().searchContact,
                                (text) => setState(() {
                                  // searchText = text;
                                }),
                              ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Consumer<ContactProvider>(
                      builder: (context, provider, __) {
                        return (provider.selectedContacts.isEmpty)
                            ? Container()
                            : Container(
                                height: 120.toHeight,
                                child: ListView.builder(
                                  itemCount: provider.selectedContacts.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) =>
                                      CircularContacts(
                                    atSign:
                                        provider.selectedContacts[index].atSign,
                                    image: (provider.selectedContacts[index]
                                                    .tags !=
                                                null &&
                                            provider.selectedContacts[index]
                                                    .tags['image'] !=
                                                null)
                                        ? CustomCircleAvatar(
                                            byteImage: provider
                                                .selectedContacts[index]
                                                .tags['image'],
                                            nonAsset: true,
                                          )
                                        : CustomCircleAvatar(
                                            image:
                                                ImageConstants.imagePlaceholder,
                                          ),
                                    name:
                                        provider.selectedContacts[index].tags !=
                                                    null &&
                                                provider.selectedContacts[index]
                                                        .tags['name'] !=
                                                    null
                                            ? provider.selectedContacts[index]
                                                .tags['name']
                                            : provider
                                                .selectedContacts[index].atSign
                                                .substring(1),
                                    onTap: () {
                                      provider.removeContacts(
                                          provider.selectedContacts[index]);
                                    },
                                  ),
                                ),
                              );
                      },
                    ),
                    SizedBox(height: 10.toHeight),
                    ProviderHandler<ContactProvider>(
                      functionName: 'get_contacts',
                      load: (provider) => provider.getContacts(),
                      successBuilder: (provider) {
                        return Container(
                          height: 600.toHeight,
                          child: ListView.separated(
                            separatorBuilder: (context, _) => Divider(
                              color:
                                  ColorConstants.dividerColor.withOpacity(0.2),
                              height: 1.toHeight,
                            ),
                            padding: EdgeInsets.only(
                                bottom: provider.selectedContacts.isEmpty
                                    ? 0
                                    : 190.toHeight),
                            scrollDirection: Axis.vertical,
                            itemCount: provider.contactList.length,
                            itemBuilder: (context, index) {
                              return GroupContactListTile(
                                isSelected: provider.selectedContacts
                                    .contains(provider.contactList[index]),
                                onAdd: () {
                                  provider.selectContacts(
                                      provider.contactList[index]);
                                },
                                onRemove: () {
                                  provider.removeContacts(
                                      provider.contactList[index]);
                                },
                                name: provider.contactList[index].tags !=
                                            null &&
                                        provider.contactList[index]
                                                .tags['name'] !=
                                            null
                                    ? provider.contactList[index].tags['name']
                                    : provider.contactList[index].atSign
                                        .substring(1),
                                atSign: provider.contactList[index].atSign,
                                image: (provider.contactList[index].tags !=
                                            null &&
                                        provider.contactList[index]
                                                .tags['image'] !=
                                            null)
                                    ? CustomCircleAvatar(
                                        byteImage: provider
                                            .contactList[index].tags['image'],
                                        nonAsset: true,
                                      )
                                    : CustomCircleAvatar(
                                        image: ImageConstants.imagePlaceholder,
                                      ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
