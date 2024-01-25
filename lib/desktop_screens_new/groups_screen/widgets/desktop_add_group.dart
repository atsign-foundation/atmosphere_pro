import 'dart:io';
import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart' as contacts;

import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/circular_contacts.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_custom_app_bar.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_floating_add_contact_button.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_contacts_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_name_text_field.dart';
import 'package:atsign_atmosphere_pro/services/picker_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_add_group_provider.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// This widget gives a screen view for displaying contacts and group details
// ignore: must_be_immutable
class DesktopAddGroup extends StatefulWidget {
  Function(bool) onDoneTap;

  DesktopAddGroup({
    Key? key,
    required this.onDoneTap,
  }) : super(key: key);

  @override
  _DesktopAddGroupState createState() => _DesktopAddGroupState();
}

class _DesktopAddGroupState extends State<DesktopAddGroup> {
  /// Instance of group service
  late GroupService _groupService;

  /// Boolean indicator of blocking action in progress
  bool blockingContact = false;

  /// Instance of contact service
  late ContactService _contactService;

  /// Boolean indicator of deleting action in progress
  bool deletingContact = false;

  late DesktopAddGroupProvider addGroupProvider;

  /// Controller of group name field
  late TextEditingController groupNameController;

  bool processing = false;

  @override
  void initState() {
    groupNameController = TextEditingController();
    _groupService = GroupService();
    _contactService = ContactService();
    addGroupProvider = context.read<DesktopAddGroupProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _groupService.fetchGroupsAndContacts(isDesktop: true);
      addGroupProvider.setGroupName('');
      addGroupProvider.setSelectedImageByteData(Uint8List(0));
    });
    super.initState();
  }

  void setSelectedContactsList(List<GroupContactsModel?> list) {
    _groupService.setSelectedContacts(list.map((e) => e?.contact).toList());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<DesktopAddGroupProvider>(
        builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: DesktopCustomAppBar(
          showTitle: true,
          centerTitle: false,
          titleText: 'Add New Group',
          titleTextStyle: CustomTextStyles.blackW50020,
          leadingIcon: InkWell(
            onTap: () {
              widget.onDoneTap.call(false);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SvgPicture.asset(
                AppVectors.icBack,
                width: 8,
                height: 20,
              ),
            ),
          ),
          showLeadingIcon: true,
          showTrailingIcon: true,
          trailingIcon: InkWell(
            onTap: () async {
              await createGroup();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 8),
              margin: const EdgeInsets.only(right: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                color: ColorConstants.orange,
              ),
              child: Text(
                'Save',
                style: CustomTextStyles.whiteW50015,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: 24.toHeight, right: 24.toHeight, bottom: 12.toHeight),
              height: double.infinity,
              child: ListView(
                children: [
                  DesktopGroupNameTextField(
                    groupNameController: groupNameController,
                    onChanged: (value) {
                      provider.setGroupName(value ?? '');
                    },
                  ),
                  SizedBox(height: 20.toHeight),
                  DropTarget(
                    onDragDone: (details) async {
                      if (details.files.length > 1) {
                        SnackbarService().showSnackbar(
                          context,
                          TextStrings.dropOneFileWarning,
                          bgColor: ColorConstants.redAlert,
                        );
                      } else {
                        provider.setSelectedImageByteData(
                          await File(details.files.first.path).readAsBytes(),
                        );
                      }
                    },
                    child: DesktopCoverImagePicker(
                      selectedImage: provider.selectedImageByteData,
                      isEdit: true,
                      onCancel: () {
                        provider.setSelectedImageByteData(Uint8List(0));
                      },
                      onPickImage: () async {
                        await PickerService.pickImage(
                          onPickedImage: (result) {
                            provider.setSelectedImageByteData(result);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.toHeight),
                  DesktopGroupContactsList(
                    asSelectionScreen: true,
                  ),
                ],
              ),
            ),
            const DesktopFloatingAddContactButton(),
          ],
        ),
      );
    });
  }

  Widget gridViewContactList(
      List<GroupContactsModel?> contactsForAlphabet, BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: SizeConfig().isTablet(context) ? 4 : 3,
          childAspectRatio: 1 / (SizeConfig().isTablet(context) ? 1.2 : 1.3)),
      shrinkWrap: true,
      itemCount: contactsForAlphabet.length,
      itemBuilder: (context, alphabetIndex) {
        return CircularContacts(
          asSelectionTile: true,
          selectSingle: false,
          selectedList: (s) {
            setSelectedContactsList(s);
          },
          onTap: () {
            if (contactsForAlphabet[alphabetIndex]!.group != null) {
              Navigator.pop(context);
              _groupService.addGroupContact(contactsForAlphabet[alphabetIndex]);
              setSelectedContactsList(GroupService().selectedGroupContacts);
            }
          },
          onLongPressed: () {
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (builder) {
                  return Container(
                    height: 200.0,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Delete'),
                            onTap: () {
                              deleteAtSign(
                                contactsForAlphabet[alphabetIndex]!.contact!,
                                closeBottomSheet: true,
                              );
                            },
                            leading: const Icon(Icons.delete),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Block'),
                            onTap: () {
                              blockUnblockContact(
                                contactsForAlphabet[alphabetIndex]!.contact!,
                                closeBottomSheet: true,
                              );
                            },
                            leading: const Icon(Icons.block),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
          onCrossPressed: () {
            if (contactsForAlphabet[alphabetIndex]!.group != null) {
              Navigator.pop(context);
              _groupService.addGroupContact(contactsForAlphabet[alphabetIndex]);
              setSelectedContactsList(GroupService().selectedGroupContacts);
            }
          },
          groupContact: contactsForAlphabet[alphabetIndex],
        );
      },
    );
  }

  blockUnblockContact(AtContact contact,
      {bool closeBottomSheet = false}) async {
    setState(() {
      blockingContact = true;
    });
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(contacts.TextStrings().blockContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await _contactService.blockUnblockContact(
        contact: contact, blockAction: true);
    await _groupService.fetchGroupsAndContacts();
    setState(() {
      blockingContact = true;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }

  deleteAtSign(AtContact contact, {bool closeBottomSheet = false}) async {
    setState(() {
      deletingContact = true;
    });
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(contacts.TextStrings().deleteContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await _contactService.deleteAtSign(atSign: contact.atSign!);
    if (_res) {
      await _groupService.removeContact(contact.atSign!);
    }
    setState(() {
      deletingContact = false;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }

  createGroup() async {
    String groupName = addGroupProvider.groupName;
    // ignore: unnecessary_null_comparison
    if (groupName != null) {
      setState(() {
        processing = true;
      });

      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        var group = AtGroup(
          groupName,
          description: 'group desc',
          displayName: groupName,
          members: Set.from(GroupService()
              .selectedGroupContacts
              .map((element) => element?.contact)),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );

        if (addGroupProvider.selectedImageByteData != null &&
            addGroupProvider.selectedImageByteData!.isNotEmpty) {
          group.groupPicture = addGroupProvider.selectedImageByteData;
        }

        var result = await GroupService().createGroup(group);
        if (result is AtGroup) {
          setState(() {
            processing = false;
          });

          widget.onDoneTap.call(true);

          GroupService().emptySelectedGroupContact();
        } else if (result != null) {
          if (mounted) {
            if (result.runtimeType == AlreadyExistsException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(TextConstants().GROUP_ALREADY_EXISTS),
                backgroundColor: ColorConstants.redAlert,
              ));
            } else if (result.runtimeType == InvalidAtSignException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result.content),
                backgroundColor: ColorConstants.redAlert,
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(TextConstants().SERVICE_ERROR),
                backgroundColor: ColorConstants.redAlert,
              ));
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(TextConstants().SERVICE_ERROR),
              backgroundColor: ColorConstants.redAlert,
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(TextConstants().EMPTY_NAME),
          backgroundColor: ColorConstants.redAlert,
        ));
      }

      setState(() {
        processing = false;
      });
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
    }
  }
}
