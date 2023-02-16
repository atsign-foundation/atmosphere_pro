import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/screens/new_version/contact_screen.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/add_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/blocked_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/contact_detail_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/group_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/trusted_contact_screen.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late TrustedContactProvider trustedProvider;
  late GroupService _groupService;

  @override
  void initState() {
    trustedProvider = context.read<TrustedContactProvider>();
    _groupService = GroupService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "Contacts",
        description: '${_groupService.listContact.length}',
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: InkWell(
            onTap: () async {
              final result = await showModalBottomSheet<bool?>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return AddContactScreen();
                },
              );
              if (result == true) {
                reloadPage();
              }
            },
            child: SvgPicture.asset(
              AppVectors.icAdd,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: <Widget>[
              _buildHeaderItem(
                title: 'Blocked atSign',
                icon: AppVectors.icBlock,
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return BlockedContactScreen();
                    },
                  );
                  reloadPage();
                },
              ),
              _buildHeaderItem(
                title: 'Trusted Senders',
                icon: AppVectors.icTrust,
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return TrustedContactScreen();
                    },
                  );
                  reloadPage();
                },
              ),
              _buildHeaderItem(
                title: 'My Groups',
                icon: AppVectors.icContactGroup,
                onTap: () {
                  return showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return GroupContactScreen();
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListContactScreen(
            contactsTrusted: trustedProvider.trustedContacts,
            onTapContact: (contact) async {
              final result = await showModalBottomSheet<bool?>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return ContactDetailScreen(
                    contact: contact,
                  );
                },
              );
              if (result != false) {
                reloadPage();
              }
            },
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeaderItem({
    required String title,
    required String icon,
    required Function onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: InkWell(
          onTap: () {
            onTap.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConstants.fadedGreyN,
              border: Border.all(
                color: ColorConstants.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SvgPicture.asset(icon),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.toFont,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.grey,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void reloadPage() async {
    await Future.delayed(Duration(milliseconds: 500), () async {
      await _groupService.fetchGroupsAndContacts();
      setState(() {});
    });
  }
}
