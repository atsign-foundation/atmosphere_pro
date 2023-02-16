import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/screens/group_view/group_view.dart';
import 'package:at_contacts_group_flutter/screens/new_group/create_group.dart';
import 'package:at_contacts_group_flutter/screens/new_version/contact_screen.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupContactScreen extends StatefulWidget {
  const GroupContactScreen({Key? key}) : super(key: key);

  @override
  State<GroupContactScreen> createState() => _GroupContactScreenState();
}

class _GroupContactScreenState extends State<GroupContactScreen> {
  late GroupService groupService;
  late TrustedContactProvider trustedProvider;

  @override
  void initState() {
    groupService = GroupService();
    trustedProvider = context.read<TrustedContactProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height - 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(27, 24, 27, 0),
                child: Row(
                  children: [
                    Container(
                      height: 2,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 31.toHeight,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorConstants.grey,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text(
                              "Close",
                              style: TextStyle(
                                fontSize: 17.toFont,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 27),
                      child: Text(
                        "My Groups",
                        style: TextStyle(
                          fontSize: 25.toFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListContactScreen(
                        showGroups: true,
                        showContacts: false,
                        isHiddenAlpha: true,
                        onTapGroup: (group) async {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            groupService.groupViewSink.add(group);
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
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 18),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateGroupScreen(
                                  trustContacts:
                                      trustedProvider.trustedContacts,
                                ),
                              ),
                            );

                            if (result == true) {
                              await groupService.fetchGroupsAndContacts();
                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 67.toHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 27),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xfff05e3f),
                                  const Color(0xffeaa743).withOpacity(0.65),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Create Group",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
