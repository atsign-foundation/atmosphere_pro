import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/group_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/circular_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/custom_list_view.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/widgets/remove_trusted_contact_dialog.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrustedContacts extends StatefulWidget {
  @override
  _TrustedContactsState createState() => _TrustedContactsState();
}

class _TrustedContactsState extends State<TrustedContacts> {
  ContactProvider _contactProvider;
  @override
  void initState() {
    _contactProvider = ContactProvider();
    // _contactProvider.getTrustedContact();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _contactProvider.getTrustedContact();
    super.didChangeDependencies();
  }

  bool toggleList = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          showTitle: true,
          title: 'Trusted Senders',
          showTrailingButton: Provider.of<ContactProvider>(context)
                  .fetchedTrustedContact
                  .isEmpty
              ? false
              : true,
          trailingIcon: Icons.add,
          isTrustedContactScreen: true,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(right: 20.toWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Text('Grid View'),
                  ),
                  Switch(
                      value: toggleList,
                      onChanged: (s) {
                        setState(() {
                          toggleList = !toggleList;
                        });
                      }),
                  Container(
                    child: Text('List View'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ProviderHandler<ContactProvider>(
                functionName: 'get_trusted_contacts',
                load: (provider) async => await provider.getTrustedContact(),
                showError: true,
                errorBuilder: (provider) => Container(),
                successBuilder: (provider) {
                  print('IN HANDLED=======>${provider.fetchedTrustedContact}');
                  return provider.fetchedTrustedContact.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                height: 160.toHeight,
                                width: 160.toHeight,
                                child: Image.asset(
                                    ImageConstants.welcomeBackground),
                              ),
                            ),
                            Text(
                              'No Trusted Senders !',
                              style: CustomTextStyles.primaryBold18,
                            ),
                            SizedBox(height: 10.toHeight),
                            Text(
                              'Would you like to add people',
                              style: CustomTextStyles.secondaryRegular16,
                            ),
                            SizedBox(
                              height: 25.toHeight,
                            ),
                            CustomButton(
                              isOrange: true,
                              buttonText: 'Add',
                              height: 40.toHeight,
                              width: 115.toWidth,
                              onPressed: () {
                                // Navigator.pushNamed(
                                //     context, Routes.GROUP_CONTACT_SCREEN,
                                //     arguments: {"isTrustedSender": true});
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupContactScreen(
                                      isTrustedScreen: true,
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      : (toggleList)
                          ? ListView.builder(
                              itemCount: provider.trustedContacts.length,
                              itemBuilder: (context, index) => ContactListTile(
                                plainView: true,
                                isSelected: false,
                                onlyRemoveMethod: true,
                                onTileTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => RemoveTrustedContact(
                                      contact:
                                          provider.fetchedTrustedContact[index],
                                    ),
                                  );
                                },
                                onAdd: () {},
                                onRemove: () {},
                                name: provider.trustedContacts[index].tags !=
                                            null &&
                                        provider.trustedContacts[index]
                                                .tags['name'] !=
                                            null
                                    ? provider
                                        .trustedContacts[index].tags['name']
                                    : provider.trustedContacts[index].atSign
                                        .substring(1),
                                atSign: provider.trustedContacts[index].atSign,
                                image: (provider.trustedContacts[index].tags !=
                                            null &&
                                        provider.trustedContacts[index]
                                                .tags['image'] !=
                                            null)
                                    ? CustomCircleAvatar(
                                        byteImage: provider
                                            .trustedContacts[index]
                                            .tags['image'],
                                        nonAsset: true,
                                      )
                                    : ContactInitial(
                                        initials: provider
                                            .trustedContacts[index].atSign
                                            .substring(1, 3),
                                      ),
                              ),
                            )
                          : GridView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1 / 1.1),
                              // padding: EdgeInsets.symmetric(horizontal: 20.toHeight),
                              shrinkWrap: true,
                              itemCount: provider.fetchedTrustedContact.length,
                              itemBuilder: (context, index) {
                                // print('IN GRID====>${provider.fetchedTrustedContact}');
                                return CircularContacts(
                                  showCross: false,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          RemoveTrustedContact(
                                        contact: provider
                                            .fetchedTrustedContact[index],
                                      ),
                                    );
                                  },
                                  atSign: provider
                                      .fetchedTrustedContact[index].atSign,
                                  name: provider.fetchedTrustedContact[index]
                                                  .tags !=
                                              null &&
                                          provider.fetchedTrustedContact[index]
                                                  .tags['name'] !=
                                              null
                                      ? provider.fetchedTrustedContact[index]
                                          .tags['name']
                                      : provider
                                          .fetchedTrustedContact[index].atSign
                                          .substring(1),
                                  image: (provider.fetchedTrustedContact[index]
                                                  .tags !=
                                              null &&
                                          provider.fetchedTrustedContact[index]
                                                  .tags['image'] !=
                                              null)
                                      ? CustomCircleAvatar(
                                          byteImage: provider
                                              .fetchedTrustedContact[index]
                                              .tags['image'],
                                          nonAsset: true,
                                          size: 50.toHeight,
                                        )
                                      : ContactInitial(
                                          initials: provider
                                              .trustedContacts[index].atSign
                                              .substring(1, 3),
                                        ),
                                );
                              },
                            );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
