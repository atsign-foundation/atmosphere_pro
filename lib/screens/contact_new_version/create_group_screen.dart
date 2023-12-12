import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/input_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/list_contact_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/create_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
  late TextEditingController groupNameController;
  late TextEditingController searchController;
  late CreateGroupProvider _provider;

  @override
  void initState() {
    groupNameController = TextEditingController();
    searchController = TextEditingController();
    _provider = context.read<CreateGroupProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateGroupProvider>(builder: (context, value, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _provider.removeSelectedImage();
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
                    child: Column(
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
                            onchange: (value) {
                              _provider.setGroupName(value);
                            },
                          ),
                        ),
                        _buildImage(value.selectedImageByteData),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 22,
                            left: 31,
                          ),
                          child: Text(
                            "Select Members ${value.listContact.isNotEmpty ? value.listContact.length : ''}",
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
                          onChange: (value) {
                            _provider.setSearchKeyword(value);
                          },
                        ),
                        Flexible(
                          child: ListContactWidget(
                            searchKeywords: value.searchKeyword,
                            trustedContacts: widget.trustContacts,
                            isSelectMultiContacts: true,
                            onSelectContacts: (contacts) {
                              _provider.addGroupContacts(contacts);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: InkWell(
                        onTap: () {
                          _provider.createGroup(
                            whenComplete: (result) {
                              if (result is AtGroup) {
                                if (!mounted) return;
                                searchController.clear();
                                groupNameController.clear();
                                _provider.removeSelectedImage();
                                _provider.resetData();
                                Navigator.of(context).pop(true);
                              } else if (result != null) {
                                if (result.runtimeType ==
                                    AlreadyExistsException) {
                                  if (!mounted) return;
                                  CustomToast().show(
                                      TextStrings().groupAlreadyExists,
                                      context);
                                } else if (result.runtimeType ==
                                    InvalidAtSignException) {
                                  CustomToast().show(result.content, context);
                                } else {
                                  if (!mounted) return;
                                  CustomToast().show(
                                      TextStrings().serviceError, context);
                                }
                              } else {
                                if (!mounted) return;
                                CustomToast()
                                    .show(TextStrings().serviceError, context);
                              }
                            },
                            whenNameIsEmpty: () {
                              if (!mounted) return;
                              CustomToast()
                                  .show(TextStrings().groupEmptyName, context);
                            },
                          );
                        },
                        child: Container(
                          height: 51.toHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 27),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: value.groupName.isNotEmpty &&
                                    value.listContact.isNotEmpty
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
              value.isLoading
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
    });
  }

  Widget _buildImage(Uint8List? selectedImage) {
    return InkWell(
      onTap: () async {
        await _provider.selectCoverImage();
      },
      child: Container(
        height: 89,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(27, 14, 27, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFECECEC),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  selectedImage,
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
}
