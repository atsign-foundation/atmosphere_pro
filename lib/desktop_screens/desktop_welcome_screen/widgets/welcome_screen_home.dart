import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_selected_contacts.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_selected_files.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:provider/provider.dart';

enum CurrentScreen { PlaceolderImage, ContactsScreen, SelectedItems }

class WelcomeScreenHome extends StatefulWidget {
  @override
  _WelcomeScreenHomeState createState() => _WelcomeScreenHomeState();
}

class _WelcomeScreenHomeState extends State<WelcomeScreenHome> {
  // bool showContent = false, showSelectedItems = false;
  CurrentScreen _currentScreen = CurrentScreen.PlaceolderImage;
  late FileTransferProvider _filePickerProvider;
  late WelcomeScreenProvider _welcomeScreenProvider;
  List _selectedList = [];
  bool isFileSending = false;

  @override
  void initState() {
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    _welcomeScreenProvider = Provider.of<WelcomeScreenProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    isFileSending = _filePickerProvider.isFileSending;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await BackendService.getInstance().syncWithSecondary();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedList.isNotEmpty) {
      _currentScreen = CurrentScreen.SelectedItems;
    }
    return Scaffold(
        body: Row(
      children: [
        Expanded(
          child: Container(
            height: SizeConfig().screenHeight - 80,
            padding: EdgeInsets.symmetric(horizontal: 50),
            color: ColorConstants.lightBlueBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome ' +
                      (AtClientManager.getInstance().atClient != null
                          ? '${AtClientManager.getInstance().atClient.getCurrentAtSign()}'
                          : ''),
                  style: CustomTextStyles.desktopBlackPlayfairDisplay26,
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                Text(
                  'Type a receipient and start sending them files.',
                  style: CustomTextStyles.desktopSecondaryRegular18,
                ),
                SizedBox(
                  height: 50.toHeight,
                ),
                Text(
                  TextStrings().welcomeSendFilesTo,
                  style: CustomTextStyles.desktopSecondaryRegular18,
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                sendFileTo(isSelectContacts: true),
                SizedBox(
                  height: 30,
                ),
                Text(TextStrings().welcomeFilePlaceholder,
                    style: CustomTextStyles.desktopSecondaryRegular18),
                SizedBox(
                  height: 20.toHeight,
                ),
                sendFileTo(),
                SizedBox(
                  height: 20.toHeight,
                ),
                (_filePickerProvider.selectedFiles.isNotEmpty &&
                        _welcomeScreenProvider.selectedContacts.isNotEmpty)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Align(
                              alignment: Alignment.centerRight,
                              child: CommonButton(
                                'Clear',
                                resetFileSelection,
                                color: ColorConstants.greyText,
                                border: 3,
                                height: 45,
                                width: 110,
                                fontSize: 20,
                                removePadding: true,
                              )),
                          SizedBox(width: 10.toWidth),
                          _welcomeScreenProvider.isSelectionItemChanged
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: isFileSending
                                      ? Container(
                                          height: 45,
                                          width: 110,
                                          color: ColorConstants.orangeColor,
                                          child: TypingIndicator(
                                            showIndicator: true,
                                            flashingCircleBrightColor:
                                                Colors.white,
                                            flashingCircleDarkColor:
                                                ColorConstants.orangeColor,
                                          ),
                                        )
                                      : CommonButton(
                                          _filePickerProvider.status[
                                                      _filePickerProvider
                                                          .SEND_FILES] ==
                                                  Status.Error
                                              ? 'Resend'
                                              : 'Send',
                                          () async {
                                            if (isFileSending) return;

                                            print('sending file');

                                            setState(() {
                                              _filePickerProvider
                                                  .updateFileSendingStatus(
                                                      true);
                                              isFileSending = true;
                                            });

                                            await _filePickerProvider.sendFileWithFileBin(
                                                _filePickerProvider
                                                    .selectedFiles,
                                                _welcomeScreenProvider
                                                    .selectedContacts);

                                            setState(() {
                                              _filePickerProvider
                                                  .updateFileSendingStatus(
                                                      false);
                                              isFileSending = false;
                                              if (_filePickerProvider.status[
                                                      _filePickerProvider
                                                          .SEND_FILES] ==
                                                  Status.Done) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'File(s) sent successfully.')));
                                                _welcomeScreenProvider
                                                        .isSelectionItemChanged =
                                                    false;
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Something went wrong.')));
                                              }
                                            });
                                          },
                                          color: isFileSending
                                              ? ColorConstants.greyText
                                              : ColorConstants.orangeColor,
                                          border: 3,
                                          height: 45,
                                          width: 110,
                                          fontSize: 20,
                                          removePadding: true,
                                        ),
                                )
                              : SizedBox(),
                        ],
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
        Expanded(child: currentScreen()),
      ],
    ));
  }

  // ignore: missing_return
  Widget currentScreen() {
    switch (_currentScreen) {
      case CurrentScreen.PlaceolderImage:
        return _selectedList.isNotEmpty
            ? _selectedItems()
            : _placeholderImage();
      case CurrentScreen.ContactsScreen:
        return GroupContactView(
            asSelectionScreen: true,
            singleSelection: false,
            showGroups: false,
            showContacts: true,
            isDesktop: true,
            selectedList: (_list) {
              Provider.of<WelcomeScreenProvider>(
                      NavService.navKey.currentContext!,
                      listen: false)
                  .updateSelectedContacts(_list);
              _welcomeScreenProvider.isSelectionItemChanged = true;
            },
            onBackArrowTap: (selectedGroupContacts) {
              if (selectedGroupContacts!.isNotEmpty) {
                CommonUtilityFunctions().shownConfirmationDialog(
                    TextStrings().contactSelectionConfirmation, () {
                  Navigator.of(NavService.navKey.currentContext!).pop();
                  setState(() {
                    _currentScreen = CurrentScreen.PlaceolderImage;
                  });
                });
              } else {
                setState(() {
                  _currentScreen = CurrentScreen.PlaceolderImage;
                });
              }
            },
            onDoneTap: () {
              setState(() {
                _currentScreen = CurrentScreen.SelectedItems;
              });
            });

      case CurrentScreen.SelectedItems:
        return _selectedItems();
    }
  }

  Widget _selectedItems() {
    return Container(
      height: SizeConfig().screenHeight - 80,
      color: ColorConstants.lightBlueBg,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DesktopSelectedContacts((val) {
              if (_welcomeScreenProvider.selectedContacts.isEmpty &&
                  _filePickerProvider.selectedFiles.isEmpty) {
                _currentScreen = CurrentScreen.PlaceolderImage;
              }
              setState(() {
                _welcomeScreenProvider.isSelectionItemChanged = true;
              });
            }),
            Divider(
              height: 20,
              thickness: 5,
            ),
            DesktopSelectedFiles((val) {
              if (_welcomeScreenProvider.selectedContacts.isEmpty &&
                  _filePickerProvider.selectedFiles.isEmpty) {
                _currentScreen = CurrentScreen.PlaceolderImage;
              }
              setState(() {});
            }, showCancelIcon: !isFileSending),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: SizeConfig().screenHeight - 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstants.welcomeDesktop,
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget sendFileTo({bool isSelectContacts = false}) {
    return InkWell(
        onTap: () async {
          if (isSelectContacts) {
            _currentScreen = CurrentScreen.ContactsScreen;
          } else {
            var file = await desktopImagePicker();
            if (file != null) {
              _filePickerProvider.selectedFiles = file;
              _welcomeScreenProvider.isSelectionItemChanged = true;
              _currentScreen = CurrentScreen.SelectedItems;
            }
          }
          setState(() {});
        },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListTile(
              title: _currentScreen != CurrentScreen.PlaceolderImage
                  ? Text(
                      (isSelectContacts
                          ? '${_welcomeScreenProvider.selectedContacts.length} contacts added'
                          : '${_filePickerProvider.selectedFiles.length} files selected'),
                      style: CustomTextStyles.desktopSecondaryRegular18)
                  : SizedBox(),
              trailing: isSelectContacts
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Image.asset(
                        ImageConstants.contactsIcon,
                        color: Colors.black,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.black,
                      ),
                    ),
            )));
  }

  resetFileSelection() {
    if (mounted) {
      setState(() {
        _filePickerProvider.selectedFiles = [];
        _welcomeScreenProvider.selectedContacts = [];
        _currentScreen = CurrentScreen.PlaceolderImage;
        _welcomeScreenProvider.isSelectionItemChanged = false;
      });
    }
  }
}
