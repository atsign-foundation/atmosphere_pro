import 'dart:io';
import 'dart:typed_data';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/input_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/list_contact_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<AtContact>? trustContacts;

  const CreateGroupScreen({
    Key? key,
    this.trustContacts,
  }) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<AtContact> listContact = [];
  late TextEditingController groupNameController;
  late TextEditingController searchController;
  late GroupService _groupService;
  bool isLoading = false;
  Uint8List? selectedImageByteData;

  @override
  void initState() {
    groupNameController = TextEditingController();
    searchController = TextEditingController();
    _groupService = GroupService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: ColorConstants.culturedColor,
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 31, top: 36),
                    child: SvgPicture.asset(
                      AppVectors.icBack,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 38,
                    bottom: 14,
                  ),
                  child: Text(
                    "Add New Group",
                    style: TextStyle(
                      fontSize: 20.toFont,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 27,
                          ),
                          child: InputWidget(
                            hintText: 'Group Name',
                            controller: groupNameController,
                            hintTextStyle: TextStyle(
                              fontSize: 14.toFont,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.grey,
                            ),
                          ),
                        ),
                        _buildImage(),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 22,
                            left: 31,
                          ),
                          child: Text(
                            "Select Members ${listContact.isNotEmpty ? listContact.length : ''}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SearchWidget(
                          controller: searchController,
                          borderColor: Colors.white,
                          backgroundColor: Colors.white,
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: ColorConstants.darkSliver,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          margin: EdgeInsets.fromLTRB(
                            28.toWidth,
                            8.toHeight,
                            28.toWidth,
                            14.toHeight,
                          ),
                        ),
                        Flexible(
                          child: ListContactWidget(
                            trustedContacts: widget.trustContacts,
                            isSelectMultiContacts: true,
                            onSelectContacts: (contacts) {
                              setState(() {
                                listContact = [];
                                for (var element in contacts) {
                                  listContact.add(element.contact!);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: InkWell(
                      onTap: () {
                        createGroup();
                      },
                      child: Container(
                        height: 51.toHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 27),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: groupNameController.text.isNotEmpty &&
                                  listContact.isNotEmpty
                              ? Colors.black
                              : ColorConstants.buttonGrey,
                        ),
                        child: const Center(
                          child: Text(
                            "Create Group",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
            isLoading
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.orange,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return InkWell(
      onTap: () async {
        var image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            selectedImageByteData = File(image.path).readAsBytesSync();
          });
        }
      },
      child: Container(
        height: 89,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(27, 14, 27, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFECECEC),
        ),
        child: selectedImageByteData != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  selectedImageByteData!,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Insert Cover Image",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Image.asset(
                      ImageConstants.icImage,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void createGroup() async {
    if (groupNameController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      var group = AtGroup(
        groupNameController.text.trim(),
        description: 'group desc',
        displayName: groupNameController.text.trim(),
        members: Set.from(listContact),
        createdBy: _groupService.currentAtsign,
        updatedBy: _groupService.currentAtsign,
      );

      if (selectedImageByteData != null) {
        group.groupPicture = selectedImageByteData;
      }

      var result = await _groupService.createGroup(group);

      setState(() {
        isLoading = false;
      });

      if (result is AtGroup) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else if (result != null) {
        if (result.runtimeType == AlreadyExistsException) {
          if (!mounted) return;
          CustomToast().show(TextStrings().groupAlreadyExists, context);
        } else if (result.runtimeType == InvalidAtSignException) {
          CustomToast().show(result.message, context);
        } else {
          if (!mounted) return;
          CustomToast().show(TextStrings().serviceError, context);
        }
      } else {
        if (!mounted) return;
        CustomToast().show(TextStrings().serviceError, context);
      }
    } else {
      if (!mounted) return;
      CustomToast().show(TextStrings().groupEmptyName, context);
    }
  }
}
