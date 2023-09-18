import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/add_contacts_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/group_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/information_card_expanded.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/circular_icon.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/desktop_contact_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

enum contactSidebar { contactDetails, addContact }

class DesktopContactScreen extends StatefulWidget {
  const DesktopContactScreen({Key? key}) : super(key: key);

  @override
  State<DesktopContactScreen> createState() => _DesktopContactScreenState();
}

class _DesktopContactScreenState extends State<DesktopContactScreen> {
  contactSidebar? sidebarView;
  var _filteredList = <BaseContact>[];
  String searchText = '';
  BaseContact? selectedContact;
  bool showGroup = true;

  // bool isRefresh = false;
  bool isSearching = false, showTrusted = false, isLoading = false;
  late TrustedContactProvider trustedProvider;
  late TextEditingController searchController;

  @override
  void initState() {
    fetchContacts();
    trustedProvider = context.read<TrustedContactProvider>();
    searchController = TextEditingController();
    super.initState();
  }

  fetchContacts() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await ContactService().fetchContacts();
      await GroupService().getAllGroupsDetails();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Color(0xFFF8F8F8),
                  padding: const EdgeInsets.only(
                      left: 50.0, top: 35, right: 50, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(),
                      Divider(
                        height: 35,
                        color: Colors.black,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height - 120,
                                child: StreamBuilder<List<BaseContact?>>(
                                    stream: ContactService().contactStream,
                                    initialData:
                                        ContactService().baseContactList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if ((snapshot.data == null ||
                                          snapshot.data!.isEmpty)) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              TextStrings().noContacts,
                                              style: CustomTextStyles
                                                  .primaryBold16,
                                            ),
                                          ],
                                        );
                                      } else {
                                        // adding trusted contact array in a map for faster access
                                        var trustedContactsMap = {};
                                        for (AtContact contact
                                            in trustedProvider
                                                .trustedContacts) {
                                          trustedContactsMap[contact.atSign] =
                                              true;
                                        }

                                        _filteredList = <BaseContact>[];

                                        for (BaseContact contact in snapshot
                                            .data! as List<BaseContact>) {
                                          if (contact.contact!.atSign!
                                              .contains(searchText)) {
                                            /// Filtering trusted contacts
                                            if (showTrusted) {
                                              if (trustedContactsMap[contact
                                                          .contact!.atSign] !=
                                                      null ||
                                                  trustedContactsMap[contact
                                                          .contact!.atSign] ==
                                                      true) {
                                                _filteredList.add(contact);
                                              }
                                            } else {
                                              _filteredList.add(contact);
                                            }
                                          }
                                        }

                                        return ListView.separated(
                                          itemCount: _filteredList.length,
                                          itemBuilder: (context, index) {
                                            var contact = _filteredList[index];

                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedContact = contact;
                                                  sidebarView = contactSidebar
                                                      .contactDetails;
                                                  showGroup = false;
                                                });
                                              },
                                              child: Container(
                                                  width: double.infinity,
                                                  key: UniqueKey(),
                                                  child: DesktopContactCard(
                                                    contact: contact.contact!,
                                                  )),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            var contact =
                                                snapshot.data![index]!;
                                            if (contact.contact!.atSign!
                                                .contains(searchText)) {
                                              return const Divider(
                                                thickness: 0.2,
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        );
                                      }
                                    })),
                          ),
                          SizedBox(width: 68),
                          showGroup
                              ? Expanded(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        120,
                                    child: GroupList(
                                      onBack: () {
                                        setState(() {
                                          showGroup = !showGroup;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showGroup = !showGroup;
                                    });
                                  },
                                  child: Text(
                                    'Show Groups',
                                    style: CustomTextStyles.darkSliverWW50015
                                        .copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              sidebarView != null
                  ? Expanded(
                      flex: 1,
                      child: getSidebarWidget(),
                    )
                  : SizedBox(),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.grey.withOpacity(0.4),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: ColorConstants.orange,
              ),
            )
        ],
      ),
    );
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
        sidebarView == null
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showTrusted = !showTrusted;
                          });
                        },
                        child: SvgPicture.asset(
                          AppVectors.icTrustActivated,
                          color: showTrusted ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  isSearching
                      ? Container(
                          margin: const EdgeInsets.only(left: 13.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              height: 40,
                              width: 308,
                              color: Colors.white,
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 8),
                                  border: InputBorder.none,
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    color: ColorConstants.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  suffixIcon: InkWell(
                                      onTap: () {
                                        searchText.isEmpty
                                            ? setState(() {
                                                isSearching = false;
                                              })
                                            : setState(() {
                                                searchText = '';
                                                searchController.clear();
                                              });
                                      },
                                      child: const Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(left: 13.0),
                          child: IconButtonWidget(
                            icon: AppVectors.icSearch,
                            onTap: () {
                              setState(() {
                                isSearching = true;
                              });
                            },
                          ),
                        ),
                  InkWell(
                    onTap: () {
                      fetchContacts();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 13.0),
                      child: CircularIcon(icon: Icons.refresh),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: CommonButton(
                      'Add contact',
                      () {
                        setState(() {
                          sidebarView = contactSidebar.addContact;
                          showGroup = false;
                        });
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
              )
            : SizedBox(),
      ],
    );
  }

  Widget getSidebarWidget() {
    if (sidebarView == contactSidebar.contactDetails) {
      return InformationCardExpanded(
        key: UniqueKey(),
        atContact: selectedContact!.contact!,
        onBack: () {
          setState(() {
            sidebarView = null;
          });
        },
      );
    } else if (sidebarView == contactSidebar.addContact) {
      return DesktopAddContactScreen(
        onBack: () {
          setState(() {
            sidebarView = null;
          });
        },
      );
    } else {
      return SizedBox();
    }
  }
}
