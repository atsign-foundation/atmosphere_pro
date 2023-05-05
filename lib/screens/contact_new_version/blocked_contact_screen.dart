import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_card_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class BlockedContactScreen extends StatefulWidget {
  const BlockedContactScreen({Key? key}) : super(key: key);

  @override
  State<BlockedContactScreen> createState() => _BlockedContactScreenState();
}

class _BlockedContactScreenState extends State<BlockedContactScreen> {
  late ContactService _contactService;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    _contactService = ContactService();
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _contactService.fetchBlockContactList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        title: Text(
          "Blocked atSigns",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              SearchWidget(
                controller: searchController,
                borderColor: Colors.white,
                backgroundColor: Colors.white,
                hintText: "Search",
                onChange: (value) {
                  setState(() {});
                },
                hintStyle: TextStyle(
                  color: ColorConstants.darkSliver,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                margin: EdgeInsets.fromLTRB(
                  44.toWidth,
                  14.toHeight,
                  29.toWidth,
                  16,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<BaseContact?>>(
                  stream: _contactService.blockedContactStream,
                  initialData: _contactService.baseBlockedList,
                  builder: (context, snapshot) {
                    if ((snapshot.connectionState == ConnectionState.waiting)) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorConstants.orange,
                        ),
                      );
                    } else {
                      var listContact = snapshot.data!;
                      listContact = listContact
                          .where(
                            (element) => (element?.contact?.atSign ?? '')
                                .contains(searchController.text),
                          )
                          .toList();

                      if (listContact.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 122,
                                width: 226,
                                child: Image.asset(
                                  ImageConstants.emptyBox,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Text(
                                  "Empty Contacts",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // renders contacts according to the initial alphabet
                      return Scrollbar(
                        radius: const Radius.circular(11),
                        child: RefreshIndicator(
                          onRefresh: () async {},
                          child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: 27,
                            shrinkWrap: true,
                            itemBuilder: (context, alphabetIndex) {
                              List<BaseContact> contactsForAlphabet = [];

                              var currentChar =
                                  String.fromCharCode(alphabetIndex + 65)
                                      .toUpperCase();

                              if (alphabetIndex == 26) {
                                currentChar = 'Others';
                              }

                              contactsForAlphabet = getContactsForAlphabets(
                                listContact,
                                currentChar,
                                alphabetIndex,
                              );

                              if (contactsForAlphabet.isEmpty) {
                                return const SizedBox();
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildChar(currentChar),
                                  _buildBlockContacts(contactsForAlphabet)
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockContacts(
    List<BaseContact> contactsForAlphabet,
  ) {
    return ListView.builder(
      itemCount: contactsForAlphabet.length,
      padding: EdgeInsets.only(left: 44, right: 28),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final contact = contactsForAlphabet[index].contact;
        return ContactCardWidget(
          contact: contact!,
          onTap: () async {
            print("unblock");
            await _contactService.blockUnblockContact(
              contact: contactsForAlphabet[index].contact!,
              blockAction: false,
            );
          },
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.block,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChar(String currentChar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              currentChar,
              style: TextStyle(
                fontSize: 20.toFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16.toWidth),
          Expanded(
            child: Divider(
              color: ColorConstants.dividerGrey,
              height: 1.toHeight,
            ),
          ),
          SizedBox(width: 31.toWidth),
        ],
      ),
    );
  }

  List<BaseContact> getContactsForAlphabets(
    List<BaseContact?> _filteredList,
    String currentChar,
    int alphabetIndex,
  ) {
    List<BaseContact> contactsForAlphabet = [];

    /// contacts, groups that does not starts with alphabets
    if (alphabetIndex == 26) {
      for (var c in _filteredList) {
        if (!RegExp(r'^[a-z]+$').hasMatch(
          (c?.contact?.atSign?[1] ?? '').toLowerCase(),
        )) {
          contactsForAlphabet.add(c!);
        }
      }
    } else {
      for (var c in _filteredList) {
        if (c?.contact != null) {
          if (c?.contact?.atSign?[1].toUpperCase() == currentChar) {
            contactsForAlphabet.add(c!);
          }
        }
      }
    }

    return contactsForAlphabet;
  }
}
