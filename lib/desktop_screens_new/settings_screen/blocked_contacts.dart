import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/widgets/desktop_blocked_contact_tile.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class DesktopBlockedContacts extends StatefulWidget {
  const DesktopBlockedContacts({Key? key}) : super(key: key);

  @override
  State<DesktopBlockedContacts> createState() => _DesktopBlockedContactsState();
}

class _DesktopBlockedContactsState extends State<DesktopBlockedContacts> {
  String searchText = '';
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ContactService().fetchBlockContactList();
    });
  }

  unblockContact(AtContact contact) async {
    var res = await ContactService()
        .blockUnblockContact(contact: contact, blockAction: false);
    await ContactService().fetchBlockContactList();
    setState(() {});
    SnackbarService().showSnackbar(
      context,
      res ? "Succesfully unblocked the contact" : "Failed to unblock contact",
      bgColor: res ? ColorConstants.successGreen : ColorConstants.redAlert,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.all(40),
      height: SizeConfig().screenHeight,
      color: ColorConstants.fadedBlue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Blocked Contacts",
                style: TextStyle(
                  fontSize: 12.toFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              isSearchActive
                  ? Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          hintText: "Search...",
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSearchActive = !isSearchActive;
                    searchText = "";
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.search,
                    size: 25,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.refresh,
                  size: 25,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 5,
          ),
          Divider(
            thickness: 1,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),

          // BODY
          Expanded(
            child: Container(
              width: SizeConfig().screenWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ContactService().blockContactList.length,
                      itemBuilder: (context, index) {
                        Uint8List? byteImage =
                            CommonUtilityFunctions().getCachedContactImage(
                          ContactService().blockContactList[index].atSign!,
                        );
                        if (ContactService()
                            .blockContactList[index]
                            .atSign!
                            .contains(searchText)) {
                          return InkWell(
                            onTap: () async {
                              await unblockContact(
                                  ContactService().blockContactList[index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: DesktopBlockedContactTile(
                                title: ContactService()
                                    .blockContactList[index]
                                    .atSign,
                                subTitle: ContactService()
                                    .blockContactList[index]
                                    .atSign,
                                showImage: byteImage != null ? true : false,
                                image: byteImage,
                              ),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.only(left: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tap on the contact to unblock them",
                              style: TextStyle(
                                color: ColorConstants.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
