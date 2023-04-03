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
import 'package:atsign_atmosphere_pro/services/overlay_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
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
    _welcomeScreenProvider = context.read<WelcomeScreenProvider>();
    filePickerModel = context.read<FileTransferProvider>();
    noteController = TextEditingController();
    isContactSelected = false;
    isFileSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "${BackendService.getInstance().currentAtSign ?? ''} ",
        description: '',
      ),
      body: Container(
        decoration: BoxDecoration(
          color: ColorConstants.welcomeScreenBG,
        ),
        width: double.infinity,
        height: SizeConfig().screenHeight,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(bottom: 100.toHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30.toWidth,
              vertical: 20.toHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig().isTablet(context) ? 33.toWidth : 0,
                  ),
                  child: Text(
                    TextStrings().selectFiles,
                    style: TextStyle(
                      fontSize: 15.toFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<FileTransferProvider>(builder: (context, provider, _) {
                  if (provider.selectedFiles.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          children: List.generate(
                            provider.selectedFiles.length,
                            (index) {
                              return FileCard(
                                fileDetail: provider.selectedFiles[index],
                                deleteFunc: () {
                                  provider.deleteFiles(index);
                                  provider.calculateSize();
                                },
                                onTap: () {
                                  openFile(
                                    provider.selectedFiles[index],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.toHeight),
                        _buildAddFilesOption()
                      ],
                    );
                  } else {
                    return InkWell(
                      onTap: selectFiles,
                      child: Container(
                        height: 142.toHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  ImageConstants.uploadIcon,
                                ),
                                SizedBox(height: 10.toHeight),
                                Text(
                                  'Upload your file(s)',
                                  style: TextStyle(
                                    color: ColorConstants.gray,
                                    fontSize: 15.toFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
                SizedBox(height: 27.toHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: SizeConfig().isTablet(context) ? 30.toWidth : 0,
                        ),
                        child: Text(
                          TextStrings().selectContacts,
                          style: TextStyle(
                            fontSize: 15.toFont,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.toHeight),
                Consumer<WelcomeScreenProvider>(
                  builder: (context, provider, _) {
                    if (provider.scrollToBottom) {
                      scrollToBottom();
                    }

                    return provider.selectedContacts.isNotEmpty
                        ? OverlappingContacts(
                            selectedList: provider.selectedContacts,
                            onchange: (isUpdate) {
                              setState(() {});
                            },
                          )
                        : SizedBox();
                  },
                ),
                _buildChoiceContact(),
                SizedBox(height: 27.toHeight),
                Container(
                  height: 94.toHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
                        color: ColorConstants.textBlack,
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(247),
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
                              fontSize: 20.toFont,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
        _choiceContact(clearSelectedContact: true);
      },
      child: Container(
        height: 56.toHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF6DED5),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20.toWidth, right: 20.toWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add atSigns',
                style: TextStyle(
                  color: ColorConstants.orange,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                size: 27,
                color: ColorConstants.orange,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddFilesOption() {
    return InkWell(
      onTap: selectFiles,
      child: Container(
        height: 61.toHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorConstants.yellow.withOpacity(0.19),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20.toWidth, right: 20.toWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Files',
                style: TextStyle(
                  color: ColorConstants.yellow,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                size: 27,
                color: ColorConstants.yellow,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _choiceContact({bool clearSelectedContact = false}) async {
    if (clearSelectedContact) {
      listContacts.clear();
    }

    final result = await showModalBottomSheet<List<GroupContactsModel>?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChoiceContactsWidget(
          selectedContacts: listContacts,
        );
      },
    );

    if (result != null) {
      listContacts = result;
      _welcomeScreenProvider.updateSelectedContacts(result);
    }
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
    OverlayService.instance.showOverlay();

    var res = await filePickerModel.sendFileWithFileBin(
      filePickerModel.selectedFiles,
      _welcomeScreenProvider.selectedContacts,
      groupName: _welcomeScreenProvider.groupName,
      notes: noteController.text,
    );

    if (mounted && res is bool) {
      filePickerModel.resetData();
      _welcomeScreenProvider.resetData();

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

  openFile(PlatformFile file) async {
    final result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      SnackbarService().showSnackbar(
        context,
        result.message,
      );
    }
  }
}
