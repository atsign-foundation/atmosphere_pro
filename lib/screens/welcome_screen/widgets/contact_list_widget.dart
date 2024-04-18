import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/add_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/create_group_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/list_contact_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactListWidget extends StatelessWidget {
  final String searchText;
  final TabController tabController;
  final List<AtContact> trustContactList;
  final Uint8List? selectedGroupImage;
  final VoidCallback onCreateGroupClose;
  final Function(List<GroupContactsModel>) onSelectContacts;
  final List<GroupContactsModel> listContact;
  final Function(int) onChangeTab;

  const ContactListWidget({
    required this.searchText,
    required this.tabController,
    required this.trustContactList,
    required this.selectedGroupImage,
    required this.onCreateGroupClose,
    required this.onSelectContacts,
    required this.listContact,
    required this.onChangeTab,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      overlayColor: MaterialStateColor.resolveWith(
        (states) => Colors.transparent,
      ),
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 56.toHeight,
            decoration: BoxDecoration(
              color: ColorConstants.backgroundTab,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 16,
            ),
            child: TabBar(
              controller: tabController,
              indicatorColor: ColorConstants.backgroundTab,
              padding: EdgeInsets.symmetric(
                horizontal: 13.toWidth,
                vertical: 7.toHeight,
              ),
              labelPadding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              tabs: [
                _buildTabBarItem(
                  index: 0,
                  currentIndex: tabController.index,
                ),
                _buildTabBarItem(
                  index: 1,
                  currentIndex: tabController.index,
                ),
              ],
              onTap: onChangeTab,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListContactWidget(
                  contactsType: ListContactType.contact,
                  trustedContacts: trustContactList,
                  searchKeywords: searchText,
                  isSelectMultiContacts: true,
                  selectedContacts: listContact,
                  onSelectContacts: onSelectContacts,
                  onTapAddButton: () async {
                    final result = await showModalBottomSheet<bool?>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return AddContactScreen();
                      },
                    );
                    if (result ?? false) {
                      await GroupService().fetchGroupsAndContacts();
                    }
                  },
                ),
                ListContactWidget(
                  contactsType: ListContactType.groups,
                  searchKeywords: searchText,
                  isSelectMultiContacts: true,
                  selectedContacts: listContact,
                  onSelectContacts: onSelectContacts,
                  onTapAddButton: () async {
                    final result = await showModalBottomSheet<bool?>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return CreateGroupScreen(
                          trustContacts: trustContactList,
                        );
                      },
                    ).whenComplete(() {
                      onCreateGroupClose.call();
                    });
                    if (result ?? false) {
                      await GroupService().fetchGroupsAndContacts();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarItem({
    required int index,
    required int currentIndex,
  }) {
    final bool isCurrentTab = index == currentIndex;
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentTab ? ColorConstants.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(125),
        ),
        child: Center(
          child: Text(
            SortedListContactType.values[index].display,
            style: TextStyle(
              color: isCurrentTab ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
