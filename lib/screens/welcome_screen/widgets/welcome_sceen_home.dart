import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/overlapping_contacts.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/images.dart';
import '../../common_widgets/app_bar_custom.dart';
import 'choice_contacts_widget.dart';

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
  List<GroupContactsModel> listContacts = [];
  late TextEditingController noteController;

  @override
  void initState() {
    noteController = TextEditingController();
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
          color: Colors.white,
        ),
        width: double.infinity,
        height: SizeConfig().screenHeight,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 30.toWidth, vertical: 20.toHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              SizeConfig().isTablet(context) ? 33.toWidth : 0,
                        ),
                        child: Text(
                          TextStrings().selectFiles,
                          style: TextStyle(
                            fontSize: 20.toFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Consumer<FileTransferProvider>(
                        builder: (context, provider, _) {
                      if (provider.selectedFiles.isNotEmpty) {
                        return InkWell(
                          onTap: selectFiles,
                          child: Container(
                            height: 40.toHeight,
                            width: 40.toHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(10),
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
                const SizedBox(height: 16),
                Consumer<FileTransferProvider>(builder: (context, provider, _) {
                  if (provider.selectedFiles.isNotEmpty) {
                    return Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      runSpacing: 5.0.toWidth,
                      spacing: 10.0.toHeight,
                      children: List.generate(
                        provider.selectedFiles.length,
                        (index) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width -
                                    50.toWidth) /
                                2,
                            child: Stack(
                              children: [
                                FileCard(
                                  fileDetail: provider.selectedFiles[index],
                                ),
                                Positioned(
                                  top: 0,
                                  right: -5,
                                  child: InkWell(
                                    onTap: () {
                                      provider.deleteFiles(index);
                                      provider.calculateSize();
                                    },
                                    child: SvgPicture.asset(
                                      AppVectors.icClose,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: selectFiles,
                      child: Container(
                        height: 142.toHeight,
                        width: 350.toWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorConstants.orangeColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Select file(s) to transfer',
                            style: TextStyle(
                              color: ColorConstants.orangeColor,
                              fontSize: 16.toFont,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
                SizedBox(height: 16.toHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
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
                    ),
                    Visibility(
                      visible: context
                          .watch<WelcomeScreenProvider>()
                          .selectedContacts
                          .isNotEmpty,
                      child: InkWell(
                        onTap: () {
                          _choiceContact();
                        },
                        child: Container(
                          height: 40.toHeight,
                          width: 40.toHeight,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 15.toFont,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.toHeight),
                // Consumer<FileTransferProvider>(builder: (context, provider, _) {
                //   if (filePickerModel.scrollToBottom) {
                //     scrollToBottom();
                //   }
                //   return SizedBox();
                // }),
                Consumer<WelcomeScreenProvider>(
                  builder: (context, provider, _) {
                    if (provider.scrollToBottom) {
                      scrollToBottom();
                    }

                    return provider.selectedContacts.isEmpty
                        ? _buildChoiceContact()
                        : OverlappingContacts(
                            selectedList: provider.selectedContacts,
                            onchange: (isUpdate) {
                              setState(() {});
                            },
                          );
                  },
                ),
                SizedBox(height: 16.toHeight),
                Container(
                  height: 94.toHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorConstants.grey),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextField(
                    controller: noteController,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 14.toFont,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Send Message (Optional)',
                      hintStyle: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.grey,
                      ),
                      border: InputBorder.none,
                      labelStyle: TextStyle(fontSize: 15.toFont),
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: 40.toHeight),
                InkWell(
                  onTap: sendFileWithFileBin,
                  child: Container(
                    height: 67.toHeight,
                    width: 350.toWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gradient: LinearGradient(
                        colors: [Color(0xffF05E3F), Color(0xffe9a642)],
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
                                fontSize: 20.toFont, color: Colors.white),
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
    );
  }

  Widget _buildChoiceContact() {
    return InkWell(
      onTap: () {
        _choiceContact(clearSelectdContact: true);
      },
      child: Container(
        height: 62.toHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorConstants.grey),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20.toWidth),
          child: Text(
            'Select atSign',
            style: TextStyle(
              color: ColorConstants.grey,
              fontSize: 15.toFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _choiceContact({bool clearSelectdContact = false}) async {
    if (clearSelectdContact) {
      listContacts.clear();
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChoiceContactsWidget(
          selectedContacts: listContacts,
          choiceContacts: (contacts) {
            setState(() {
              listContacts = contacts;
            });
          },
        );
      },
    );
  }

  selectFiles() async {
    await providerCallback<FileTransferProvider>(context,
        task: (provider) => provider.pickFiles(provider.FILES),
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
      notes: noteController.text,
    );

    if (mounted && res is bool) {
      setState(() {
        isFileShareFailed = !res;
        listContacts.clear();
        noteController.clear();
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
