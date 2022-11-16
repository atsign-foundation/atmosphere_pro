import 'dart:async';
import 'dart:ui';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_heading.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_outlined_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/trusted_senders.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/overlapping_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_contact_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WelcomeScreenHome extends StatefulWidget {
  @override
  _WelcomeScreenHomeState createState() => _WelcomeScreenHomeState();
}

class _WelcomeScreenHomeState extends State<WelcomeScreenHome> {
  bool? isContactSelected;
  bool? isFileSelected;
  late WelcomeScreenProvider _welcomeScreenProvider;
  HistoryProvider? historyProvider;
  List<AtContact> selectedList = [];
  bool isExpanded = true,
      isFileShareFailed = false,
      isSentFileEntrySaved = true;
  ScrollController scrollController = ScrollController();
  late FileTransferProvider filePickerModel;
  String? notes;
  FocusNode _notesFocusNode = FocusNode();
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    isContactSelected = false;
    isFileSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filePickerModel = Provider.of<FileTransferProvider>(context);
    _welcomeScreenProvider = Provider.of<WelcomeScreenProvider>(
      context,
    );

    return Container(
        width: double.infinity,
        height: SizeConfig().screenHeight,
        child: Container(
          width: double.infinity,
          height: SizeConfig().screenHeight,
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.toWidth, vertical: 20.toHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TextStrings().welcome,
                              semanticsLabel: TextStrings().welcome,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                  fontSize: 26.toFont,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: switchAtsign,
                              child: Text(
                                BackendService.getInstance().currentAtSign!,
                                style: GoogleFonts.playfairDisplay(
                                  textStyle: TextStyle(
                                    fontSize: 26.toFont,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    color: ColorConstants.orangeColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Text(
                              TextStrings().welcomeRecipient,
                              style: TextStyle(
                                color: ColorConstants.fadedText,
                                fontSize: 13.toFont,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: 67.toHeight,
                            ),
                            Text(
                              TextStrings().welcomeSendFilesTo,
                              style: TextStyle(
                                color: ColorConstants.fadedText,
                                fontSize: 12.toFont,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: 20.toHeight,
                            ),
                            SelectContactWidget(
                              (b) {
                                setState(() {
                                  isContactSelected = b;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Consumer<FileTransferProvider>(
                                builder: (context, provider, _) {
                              if (filePickerModel.scrollToBottom) {
                                scrollToBottom();
                              }
                              return SizedBox();
                            }),
                            Consumer<WelcomeScreenProvider>(
                              builder: (context, provider, _) {
                                if (provider.scrollToBottom) {
                                  scrollToBottom();
                                }
                                if ((provider.selectedContacts.isEmpty)) {
                                  return Container();
                                } else {
                                  return OverlappingContacts(
                                    selectedList: provider.selectedContacts,
                                    onChnage: (isUpdate) {
                                      setState(() {});
                                    },
                                  );
                                }
                              },
                            ),
                            SizedBox(
                              height: 20.toHeight,
                            ),
                            SelectFileWidget(
                              (b) {
                                setState(() {
                                  isFileSelected = b;
                                });
                              },
                              (_str) {
                                setState(() {
                                  notes = _str;
                                });
                              },
                              initialValue: notes,
                            ),
                            SizedBox(
                              height: (_welcomeScreenProvider
                                              .selectedContacts !=
                                          null &&
                                      _welcomeScreenProvider
                                          .selectedContacts.isNotEmpty &&
                                      filePickerModel.selectedFiles.isNotEmpty)
                                  ? 20.toHeight
                                  : 60.toHeight,
                            ),
                            (_welcomeScreenProvider.selectedContacts != null &&
                                    _welcomeScreenProvider
                                        .selectedContacts.isNotEmpty &&
                                    filePickerModel.selectedFiles.isNotEmpty)
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: ColorConstants.inputFieldColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10.toWidth,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            focusNode: _notesFocusNode,
                                            controller: _notesController,
                                            // initialValue: notes,
                                            decoration: InputDecoration(
                                              hintText: TextStrings()
                                                  .welcomeAddTranscripts,
                                              hintStyle: TextStyle(
                                                color: ColorConstants.fadedText,
                                                fontSize: 14.toFont,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              border: InputBorder.none,
                                              fillColor: ColorConstants
                                                  .inputFieldColor,
                                              focusColor: ColorConstants
                                                  .inputFieldColor,
                                              hoverColor: ColorConstants
                                                  .inputFieldColor,
                                            ),
                                            style: TextStyle(
                                              color: ColorConstants.fadedText,
                                              fontSize: 14.toFont,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            onChanged: (String txt) {
                                              setState(() {
                                                notes = txt;
                                              });
                                            },
                                          ),
                                        ),
                                        notes != null
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    notes = null;
                                                  });
                                                  _notesController.clear();
                                                },
                                                child: Icon(Icons.clear,
                                                    color: Colors.black),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _notesFocusNode);
                                                },
                                                child: Icon(Icons.edit,
                                                    color: Colors.black),
                                              ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 30.toHeight,
                            ),
                            if (_welcomeScreenProvider.selectedContacts !=
                                    null &&
                                _welcomeScreenProvider
                                    .selectedContacts.isNotEmpty &&
                                filePickerModel.selectedFiles.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CommonButton('Clear', () {
                                    setState(() {
                                      isFileShareFailed = false;
                                      _welcomeScreenProvider.selectedContacts
                                          .clear();
                                      _welcomeScreenProvider
                                          .resetSelectedContactsStatus();
                                      filePickerModel.selectedFiles.clear();
                                      filePickerModel
                                          .resetSelectedFilesStatus();
                                      notes = null;
                                      _notesController.clear();
                                    });
                                  }),
                                  Expanded(child: SizedBox()),
                                  Visibility(
                                      visible: ((!_welcomeScreenProvider
                                                  .hasSelectedContactsChanged &&
                                              !filePickerModel
                                                  .hasSelectedFilesChanged) &&
                                          isFileShareFailed),
                                      child: CommonButton(
                                        TextStrings().buttonResend,
                                        reAttemptSendingFiles,
                                        color: Colors.amber[800],
                                      )),
                                  (_welcomeScreenProvider
                                              .hasSelectedContactsChanged ||
                                          filePickerModel
                                                  .hasSelectedFilesChanged &&
                                              !isFileShareFailed)
                                      ? CommonButton(
                                          TextStrings().buttonSend,
                                          sendFileWithFileBin,
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              SizedBox(
                                height: 60.toHeight,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizeConfig().isTablet(context)
                      ? Container(
                          height: SizeConfig().screenHeight,
                          width: 100,
                          child: SideBarWidget(
                            isExpanded: false,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              SizeConfig().isTablet(context)
                  ? Container(
                      height: 100,
                      width: SizeConfig().screenWidth - 100,
                      child: Customheading(),
                    )
                  : SizedBox(),
              SizeConfig().isTablet(context)
                  ? Positioned(
                      right: 80,
                      top: 100,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.black,
                        ),
                        child: Builder(
                          builder: (context) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                  WelcomeScreenProvider().isExpanded = true;
                                });

                                Scaffold.of(context).openEndDrawer();
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ));
  }

  scrollToBottom() {
    Timer(
      Duration(milliseconds: 200),
      () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
        _welcomeScreenProvider.scrollToBottom = false;
        filePickerModel.scrollToBottom = false;
      },
    );
  }

  reAttemptSendingFiles() async {
    if (mounted) {
      setState(() {
        isFileShareFailed = false;
      });
    }

    // when entry is not added in sent history.
    if (!isSentFileEntrySaved) {
      sendFileWithFileBin();
      return;
    }

    // when entry is added in sent history but notifications didn't go through.
    var res = await filePickerModel.reAttemptInSendingFiles();

    if (!res) {
      if (mounted) {
        setState(() {
          isFileShareFailed = true;
        });
      }
    }
  }

  sendFileWithFileBin() async {
    if (mounted) {
      setState(() {
        // assuming file share record will be saved in sent history.
        isSentFileEntrySaved = true;
        isFileShareFailed = false;
      });
    }
    _welcomeScreenProvider.resetSelectedContactsStatus();
    filePickerModel.resetSelectedFilesStatus();
    var res = await filePickerModel.sendFileWithFileBin(
      filePickerModel.selectedFiles,
      _welcomeScreenProvider.selectedContacts,
      groupName: _welcomeScreenProvider.groupName,
      notes: notes,
    );

    if (mounted && res is bool) {
      setState(() {
        isFileShareFailed = !res;
      });
    } else if (res == null) {
      if (mounted) {
        setState(() {
          isFileShareFailed = true;
          isSentFileEntrySaved = false;
        });
      }
    }
  }

  switchAtsign() async {
    var atSignList = await KeychainUtil.getAtsignList();
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.transparent,
      builder: (context) => AtSignBottomSheet(
        atSignList: atSignList,
      ),
    );
  }
}
