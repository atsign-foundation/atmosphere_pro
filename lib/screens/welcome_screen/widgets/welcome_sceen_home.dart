import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_heading.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/overlapping_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_contact_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/images.dart';
import '../../common_widgets/app_bar_custom.dart';

class WelcomeScreenHome extends StatefulWidget {
  @override
  _WelcomeScreenHomeState createState() => _WelcomeScreenHomeState();
}

class _WelcomeScreenHomeState extends State<WelcomeScreenHome> {
  bool isContactSelected = false;
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

    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "${BackendService.getInstance().currentAtSign ?? ''} ",
        description: '',
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              ImageConstants.welcomeBackground,
            ),
            fit: BoxFit.fill,
          ),
          // shape: BoxShape.circle,
          // gradient: LinearGradient(
          //   colors: [Color(0xffF05E3F), Color(0xffe9a642)],
          //   stops: [0.1, 0.8],
          // ),
        ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig().isTablet(context)
                                        ? 30.toWidth
                                        : 0),
                                child: Text(
                                  TextStrings().selectFiles,
                                  style: TextStyle(
                                    fontSize: 20.toFont,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Consumer<FileTransferProvider>(
                                  builder: (context, provider, _) {
                                if (provider.selectedFiles.isNotEmpty) {
                                  return InkWell(
                                    onTap: SelectFiles,
                                    child: Container(
                                      color: Colors.black,
                                      padding: EdgeInsets.all(10),
                                      margin:
                                          EdgeInsets.only(right: 30.toWidth),
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 15.toFont,
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }),
                            ],
                          ),
                          SizedBox(height: 16),
                          Consumer<FileTransferProvider>(
                              builder: (context, provider, _) {
                            if (provider.selectedFiles.isEmpty) {
                              return InkWell(
                                onTap: SelectFiles,
                                child: Container(
                                  height: 142.toHeight,
                                  width: 350.toWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: ColorConstants.orangeColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Select file(s) to transfer',
                                      style: TextStyle(
                                          color: ColorConstants.orangeColor,
                                          fontSize: 16.toFont),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          }),
                          SizedBox(height: 16),
                          Consumer<FileTransferProvider>(
                              builder: (context, provider, _) {
                            if (provider.selectedFiles.isNotEmpty) {
                              return Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                runSpacing: 5.0.toWidth,
                                spacing: 10.0.toHeight,
                                children: List.generate(
                                    provider.selectedFiles.length, (index) {
                                  return SizedBox(
                                    width: (320.toWidth) / 2,
                                    child: Stack(
                                      children: [
                                        FileCard(
                                          fileDetail:
                                              provider.selectedFiles[index],
                                        ),
                                        Positioned(
                                          top: -10,
                                          right: -10,
                                          child: InkWell(
                                            onTap: () {
                                              provider.selectedFiles
                                                  .removeAt(index);
                                              provider.calculateSize();
                                              provider.notifyListeners();
                                            },
                                            child: Container(
                                              width: 40.toHeight,
                                              height: 40.toHeight,
                                              child: FittedBox(
                                                fit: BoxFit.fill,
                                                child: Image.asset(
                                                    ImageConstants.closeIcon),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return SizedBox();
                            }
                          }),
                          SizedBox(height: 16.toHeight),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig().isTablet(context)
                                        ? 30.toWidth
                                        : 0),
                                child: Text(
                                  TextStrings().selectContacts,
                                  style: TextStyle(
                                    fontSize: 20.toFont,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Consumer<WelcomeScreenProvider>(
                                builder: (context, provider, _) {
                                  if (provider.selectedContacts.isNotEmpty) {
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                        color: Colors.black,
                                        padding: EdgeInsets.all(10),
                                        margin:
                                            EdgeInsets.only(right: 30.toWidth),
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.white,
                                          size: 15.toFont,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.toHeight),
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
                                return SelectContactWidget(
                                  (b) {
                                    print(b);
                                    setState(() {
                                      isContactSelected = b;
                                    });
                                  },
                                );
                              } else {
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
                              }
                            },
                          ),
                          SizedBox(height: 16.toHeight),
                          Container(
                            width: 350.toWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorConstants.grey),
                            ),
                            child: TextField(
                              onChanged: (String txt) {
                                setState(() {
                                  notes = txt;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Send Message (Optional)',
                                labelStyle: TextStyle(fontSize: 15.toFont),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      // color: ColorConstants.grey,
                                      ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          SizedBox(height: 40.toHeight),
                          InkWell(
                            onTap: sendFileWithFileBin,
                            child: Container(
                              height: 67.toHeight,
                              width: 350.toWidth,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffF05E3F),
                                    Color(0xffe9a642)
                                  ],
                                  stops: [0.1, 0.8],
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Transfer Now',
                                      style: TextStyle(
                                          fontSize: 20.toFont,
                                          color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 20.toFont)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 100)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SelectFiles() async {
    await providerCallback<FileTransferProvider>(context,
        task: (provider) => provider.pickFiles(provider.MEDIA),
        taskName: (provider) => provider.PICK_FILES,
        onSuccess: (provider) {},
        onError: (err) => ErrorDialog().show(err.toString(), context: context));
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
    if (filePickerModel.selectedFiles.isEmpty) {
      SnackbarService().showSnackbar(
        context,
        'No files selected',
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

    if (_welcomeScreenProvider.selectedContacts.isEmpty) {
      SnackbarService().showSnackbar(
        context,
        'No atSign selected',
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

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
