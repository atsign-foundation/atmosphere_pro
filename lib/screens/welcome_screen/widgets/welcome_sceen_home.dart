import 'dart:async';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_heading.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/overlapping_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_contact_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
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
  bool isContactSelected;
  bool isFileSelected;
  WelcomeScreenProvider _welcomeScreenProvider;
  HistoryProvider historyProvider;
  List<AtContact> selectedList = [];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();
  var filePickerModel;

  @override
  void initState() {
    isContactSelected = false;
    isFileSelected = false;
    _welcomeScreenProvider = WelcomeScreenProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filePickerModel = Provider.of<FileTransferProvider>(context);

    return Container(
        width: double.infinity,
        height: SizeConfig().screenHeight,
        child: Container(
          width: double.infinity,
          height: SizeConfig().screenHeight,
          child: Stack(
            children: [
              SizeConfig().isTablet(context)
                  ? Container(
                      height: 90.toHeight,
                      width: 90.toHeight,
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
                              TextStrings().welcomeUser(
                                  BackendService.getInstance()
                                              .atClientInstance !=
                                          null
                                      ? BackendService.getInstance()
                                          .currentAtSign
                                      : ''),
                              style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                  fontSize: 26.toFont,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
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
                                scrolToBottom();
                              }
                              return SizedBox();
                            }),
                            Consumer<WelcomeScreenProvider>(
                              builder: (context, provider, _) {
                                return (provider.selectedContacts.isEmpty)
                                    ? Container()
                                    : OverlappingContacts(
                                        selectedList: provider.selectedContacts,
                                        onChnage: (isUpdate) {
                                          setState(() {});
                                        },
                                      );
                              },
                            ),
                            SizedBox(
                              height: 40.toHeight,
                            ),
                            SelectFileWidget(
                              (b) {
                                setState(() {
                                  isFileSelected = b;
                                });
                              },
                            ),
                            SizedBox(
                              height: 60.toHeight,
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
                                      _welcomeScreenProvider.selectedContacts
                                          .clear();
                                      _welcomeScreenProvider
                                          .resetSelectedContactsStatus();
                                      filePickerModel.selectedFiles.clear();
                                      filePickerModel
                                          .resetSelectedFilesStatus();
                                    });
                                  }),
                                  (_welcomeScreenProvider
                                              .hasSelectedContactsChanged ||
                                          filePickerModel
                                              .hasSelectedFilesChanged)
                                      ? CommonButton(
                                          TextStrings().buttonSend,
                                          () async {
                                            _welcomeScreenProvider
                                                .resetSelectedContactsStatus();
                                            filePickerModel
                                                .resetSelectedFilesStatus();
                                            await filePickerModel
                                                .sendFileWithFileBin(
                                                    filePickerModel
                                                        .selectedFiles,
                                                    _welcomeScreenProvider
                                                        .selectedContacts);
                                          },
                                        )
                                      : SizedBox()
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
            ],
          ),
        ));
  }

  scrolToBottom() {
    Timer(
      Duration(milliseconds: 200),
      () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );

        filePickerModel.scrollToBottom = false;
      },
    );
  }
}
