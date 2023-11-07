import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/screens/group_view/group_view.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/add_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/contact_detail_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/create_group_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/list_contact_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/create_group_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TrustedContactProvider trustedProvider;
  late CreateGroupProvider createGroupProvider;
  late ContactProvider contactProvider;
  late GroupService _groupService;
  late TabController _tabController;
  late TextEditingController searchController;

  @override
  void initState() {
    trustedProvider = context.read<TrustedContactProvider>();
    createGroupProvider = context.read<CreateGroupProvider>();
    contactProvider = context.read<ContactProvider>();
    _groupService = GroupService();
    _tabController = TabController(
        length: 3, initialIndex: contactProvider.indexTab, vsync: this);
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ContactProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: ColorConstants.background,
        resizeToAvoidBottomInset: false,
        appBar: AppBarCustom(
          title: "Contacts",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: () async {
                if (provider.indexTab == 2) {
                  final result = await showModalBottomSheet<bool?>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return CreateGroupScreen(
                        trustContacts: trustedProvider.trustedContacts,
                      );
                    },
                  );
                  if (createGroupProvider.selectedImageByteData != null) {
                    createGroupProvider.removeSelectedImage();
                  }
                  if (result ?? false) {
                    await _groupService.fetchGroupsAndContacts();
                    provider.notify();
                  }
                } else {
                  final result = await showModalBottomSheet<bool?>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return const AddContactScreen();
                    },
                  );

                  if (result == true) {
                    await reloadPage();
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ColorConstants.orange,
                  borderRadius: BorderRadius.circular(46),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Text(
                  provider.indexTab == 2 ? "Add Group" : "Add Contact",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: buildBody(),
      );
    });
  }

  Widget buildBody() {
    return Consumer<ContactProvider>(builder: (context, provider, child) {
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
            SearchWidget(
              controller: searchController,
              borderColor: Colors.white,
              backgroundColor: Colors.white,
              hintText: "Search",
              hintStyle: const TextStyle(
                color: ColorConstants.darkSliver,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              margin: EdgeInsets.fromLTRB(
                36.toWidth,
                24.toHeight,
                36.toWidth,
                0,
              ),
              onChange: (value) {
                provider.notify();
              },
            ),
            Container(
              height: 56.toHeight,
              decoration: BoxDecoration(
                color: ColorConstants.backgroundTab,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 16,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: 13.toWidth,
                  vertical: 7.toHeight,
                ),
                labelPadding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                tabs: [
                  _buildTabBarItem(index: 0, currentIndex: provider.indexTab),
                  _buildTabBarItem(index: 1, currentIndex: provider.indexTab),
                  _buildTabBarItem(index: 2, currentIndex: provider.indexTab),
                ],
                onTap: (index) {
                  provider.setIndexTab(index);
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListContactWidget(
                    contactsType: ListContactType.contact,
                    trustedContacts: trustedProvider.trustedContacts,
                    searchKeywords: searchController.text,
                    onTapContact: (contact) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailScreen(
                            contact: contact,
                          ),
                        ),
                      );

                      if (result != false) {
                        await reloadPage();
                      }
                    },
                    onTapAddButton: () async {
                      final result = await showModalBottomSheet<bool?>(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return const AddContactScreen();
                        },
                      );
                      if (result == true) {
                        await reloadPage();
                      }
                    },
                  ),
                  ListContactWidget(
                    contactsType: ListContactType.trusted,
                    trustedContacts: trustedProvider.trustedContacts,
                    searchKeywords: searchController.text,
                    onTapContact: (contact) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailScreen(
                            contact: contact,
                            onTrustFunc: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListContactWidget(
                    contactsType: ListContactType.groups,
                    searchKeywords: searchController.text,
                    onTapGroup: (group) async {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        _groupService.groupViewSink.add(group);
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupView(
                            group: group,
                          ),
                        ),
                      );
                    },
                    onTapAddButton: () async {
                      final result = await showModalBottomSheet<bool?>(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return CreateGroupScreen(
                            trustContacts: trustedProvider.trustedContacts,
                          );
                        },
                      );
                      if (createGroupProvider.selectedImageByteData != null) {
                        createGroupProvider.removeSelectedImage();
                      }
                      if (result ?? false) {
                        await _groupService.fetchGroupsAndContacts();
                        provider.notify();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
            ListContactType.values[index].display,
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

  Future<void> reloadPage() async {
    await Future.delayed(const Duration(milliseconds: 500), () async {
      await _groupService.fetchGroupsAndContacts();
      contactProvider.notify();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
