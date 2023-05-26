import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/avatar_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_attachment_card.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/option_dialog.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../data_models/file_transfer.dart';
import '../common_widgets/provider_handler.dart';

class ContactDetailScreen extends StatefulWidget {
  final AtContact contact;
  final Function()? onTrustFunc;

  const ContactDetailScreen({
    Key? key,
    required this.contact,
    this.onTrustFunc,
  }) : super(key: key);

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late TrustedContactProvider _trustedContactProvider;
  late ContactService _contactService;
  late WelcomeScreenProvider _welcomeScreenProvider;
  late HistoryProvider historyProvider;
  GlobalKey optionKey = GlobalKey();
  TextEditingController nicknameController = TextEditingController();
  bool isTrusted = false;
  bool isLoading = false;
  bool isEditNickname = false;

  @override
  void initState() {
    _trustedContactProvider = TrustedContactProvider();
    _welcomeScreenProvider = WelcomeScreenProvider();
    _contactService = ContactService();
    historyProvider =
        Provider.of<HistoryProvider>(NavService.navKey.currentContext!);
    checkTrustedContact();
    nicknameController.text = widget.contact.tags?['nickname'] ?? "";
    super.initState();
  }

  void checkTrustedContact() {
    _trustedContactProvider.trustedContacts.forEach((element) {
      if (element.atSign == widget.contact.atSign) {
        setState(() {
          isTrusted = true;
        });
      }
    });
  }

  filterReceivedFiles(String atSign, List<FileTransfer> receivedFiles) {
    var tempfiles = [];

    for (var file in receivedFiles) {
      if (file.sender == atSign) {
        tempfiles.add(file);
      }
    }

    return tempfiles;
  }

  editNickname() async {
    setState(() {
      isLoading = true;
    });
    AtContact contact = widget.contact;
    contact.tags =
        await _contactService.getContactDetails(contact.atSign, null);
    contact.tags!['nickname'] = nicknameController.text;
    var res = await _contactService.atContactImpl.add(contact);
    if (res == true) {
      await SnackbarService()
          .showSnackbar(context, "Successfully updated nickname");
    } else {
      await SnackbarService()
          .showSnackbar(context, "Failed to update nickname");
    }
    setState(() {
      isEditNickname = false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 31),
            child: Icon(
              Icons.arrow_back_ios,
            ),
          ),
        ),
        actions: [
          _buildMoreIcon(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: double.infinity,
          // width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: <Widget>[
                    AvatarWidget(
                      size: 100,
                      borderRadius: 50,
                      contact: widget.contact,
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          isEditNickname
                              ? Text(
                                  "Nickname",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500),
                                )
                              : SizedBox(),
                          SizedBox(height: 4),
                          Flexible(
                            child: isEditNickname
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                              left: 16,
                                            ),
                                            hintText: 'Enter Nickname',
                                            hintStyle: TextStyle(
                                              fontSize: 14.toFont,
                                              fontWeight: FontWeight.w500,
                                              color: ColorConstants.textBlack,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none,
                                            ),
                                            labelStyle: TextStyle(
                                              fontSize: 14.toFont,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                nicknameController.clear();
                                              },
                                              child: Icon(
                                                Icons.clear,
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          controller: nicknameController,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    widget.contact.tags?['nickname'] ??
                                        widget.contact.atSign!.substring(1),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: isEditNickname
                                ? _buildButtonIcon(
                                    height: 36,
                                    backgroundColor: Colors.black,
                                    borderRadius: 5,
                                    title: 'Save',
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.toFont,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    useLoadingIndicator: true,
                                    onTap: () async {
                                      await editNickname();
                                    },
                                  )
                                : Text(
                                    widget.contact.atSign ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              isTrusted
                  ? _buildButtonIcon(
                      title: "Trusted",
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.toFont,
                        fontWeight: FontWeight.w500,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 44),
                      imageUrl: AppVectors.icWhiteTrust,
                      backgroundColor: ColorConstants.orange,
                      onTap: () async {
                        await _trustedContactProvider
                            .removeTrustedContacts(widget.contact);
                        setState(() {
                          isTrusted = false;
                        });
                      },
                    )
                  : _buildButtonIcon(
                      title: "Add To Trusted",
                      titleStyle: TextStyle(
                        color: ColorConstants.portlandOrange,
                        fontSize: 14.toFont,
                        fontWeight: FontWeight.w500,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 44),
                      imageUrl: AppVectors.icTrustActivated,
                      backgroundColor: ColorConstants.unbleachedSilk,
                      onTap: () async {
                        await _trustedContactProvider
                            .addTrustedContacts(widget.contact);
                        setState(() {
                          isTrusted = true;
                        });
                      },
                    ),
              const SizedBox(height: 13),
              _buildButtonIcon(
                title: "Transfer File",
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14.toFont,
                  fontWeight: FontWeight.bold,
                ),
                margin: EdgeInsets.symmetric(horizontal: 44),
                imageUrl: AppVectors.icArrow,
                backgroundColor: Colors.black,
                onTap: () {
                  Navigator.of(context).pop(false);
                  widget.onTrustFunc?.call();
                  _welcomeScreenProvider.selectedContacts = [
                    GroupContactsModel(
                      contactType: ContactsType.CONTACT,
                      contact: widget.contact,
                    ),
                  ];
                  _welcomeScreenProvider.changeBottomNavigationIndex(0);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 38),
                child: Text(
                  "Attachments",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 38),
                child: Text(
                  "Files ${widget.contact.atSign ?? ''} has sent you",
                  style: TextStyle(
                    fontSize: 10.toFont,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.oldSliver,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ProviderHandler<HistoryProvider>(
                functionName: historyProvider.RECEIVED_HISTORY,
                showError: false,
                successBuilder: (provider) {
                  var files = filterReceivedFiles(widget.contact.atSign ?? "",
                      provider.receivedHistoryLogs);

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: files.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      List<Widget> list = [];
                      for (var file in files[index].files) {
                        print("path: ${file.path}");

                        list.add(
                          ContactAttachmentCard(
                            fileTransfer: files[index],
                            singleFile: file,
                            fromContact: true,
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: list,
                      );
                    },
                  );
                },
                // errorBuilder: (provider) => Center(
                //   child: Text(TextStrings().errorOccured),
                // ),
                load: (provider) async {
                  await provider.getReceivedHistory();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon({
    String title = '',
    TextStyle? titleStyle,
    String? imageUrl,
    Color backgroundColor = Colors.black,
    EdgeInsetsGeometry? margin,
    Function()? onTap,
    double height = 51,
    double borderRadius = 10,
    bool useLoadingIndicator = false,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: margin,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: useLoadingIndicator && isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                    if (imageUrl != null) const SizedBox(width: 14),
                    if (imageUrl != null)
                      SvgPicture.asset(
                        imageUrl,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return InkWell(
      onTap: () {
        RenderBox box =
            optionKey.currentContext!.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        showDialog(
          context: context,
          builder: (BuildContext contextDialog) {
            return OptionDialog(
              position: position,
              editNickNameFunc: () {
                setState(() {
                  isEditNickname = true;
                });
              },
              blockFunc: () async {
                await _contactService.blockUnblockContact(
                  contact: widget.contact,
                  blockAction: true,
                );
                Navigator.of(context).pop();
              },
              deleteFunc: () async {
                await _contactService.deleteAtSign(
                  atSign: widget.contact.atSign!,
                );
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
      child: Padding(
        key: optionKey,
        padding: EdgeInsets.only(right: 32),
        child: Icon(
          Icons.more_horiz,
        ),
      ),
    );
  }
}
