import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
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
  bool isFileSending = false,
      isSentFileEntrySaved = true,
      isFileShareFailed = false;
  String? notes;
  FocusNode _notesFocusNode = FocusNode();
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    _welcomeScreenProvider = Provider.of<WelcomeScreenProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    isFileSending = _filePickerProvider.isFileSending;

    _welcomeScreenProvider.addListener(() {
      if (_selectedList.isEmpty &&
          _filePickerProvider.selectedFiles.isEmpty &&
          _currentScreen != CurrentScreen.PlaceolderImage) {
        setState(() {
          _currentScreen = CurrentScreen.PlaceolderImage;
        });
      }
    });

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
                  'Select a recipient and start sending them files.',
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
                (_welcomeScreenProvider.selectedContacts != null &&
                        _welcomeScreenProvider.selectedContacts.isNotEmpty &&
                        _filePickerProvider.selectedFiles.isNotEmpty)
                    ? Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                focusNode: _notesFocusNode,
                                controller: _notesController,
                                decoration: InputDecoration(
                                  hintText: TextStrings().welcomeAddTranscripts,
                                  hintStyle: CustomTextStyles
                                      .desktopSecondaryRegular16,
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  filled: true,
                                ),
                                style:
                                    CustomTextStyles.desktopSecondaryRegular18,
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
                                    child:
                                        Icon(Icons.clear, color: Colors.black),
                                  )
                                : InkWell(
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(_notesFocusNode);
                                    },
                                    child:
                                        Icon(Icons.edit, color: Colors.black),
                                  ),
                            SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: (_welcomeScreenProvider.selectedContacts != null &&
                          _welcomeScreenProvider.selectedContacts.isNotEmpty &&
                          _filePickerProvider.selectedFiles.isNotEmpty)
                      ? 10.toHeight
                      : 0,
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
                                          isFileShareFailed ? 'Resend' : 'Send',
                                          () async {
                                            await Provider.of<MyFilesProvider>(
                                                    NavService
                                                        .navKey.currentContext!,
                                                    listen: false)
                                                .deleteMyfilekeys();
                                            if (isFileSending) return;

                                            if (isFileShareFailed) {
                                              await reAttemptSendingFiles();
                                              return;
                                            }

                                            await sendFileWithFileBin();
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
            showGroups: true,
            showContacts: true,
            isDesktop: true,
            contactSelectedHistory: _welcomeScreenProvider.selectedContacts,
            onContactsTap: (_list) {
              Provider.of<WelcomeScreenProvider>(
                      NavService.navKey.currentContext!,
                      listen: false)
                  .updateSelectedContacts(_list, notifyListeners: false);
              _welcomeScreenProvider.isSelectionItemChanged = true;
            },
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
                  //// TODO: If we want to clear the selected list of contacts if user goes back
                  // Provider.of<WelcomeScreenProvider>(
                  //         NavService.navKey.currentContext!,
                  //         listen: false)
                  //     .updateSelectedContacts([]);

                  Navigator.of(NavService.navKey.currentContext!).pop();
                  setState(() {
                    _currentScreen = CurrentScreen.PlaceolderImage;
                  });
                });
              } else {
                Provider.of<WelcomeScreenProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .updateSelectedContacts(
                        []); // clear selected list if nothing is selected
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
                isFileShareFailed = false;
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
              isFileShareFailed = false;
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
              GroupService().selectedGroupContacts = [];
              GroupService().selectedContactsSink.add([]);
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
        isFileShareFailed = false;
        _filePickerProvider.selectedFiles = [];
        _welcomeScreenProvider.selectedContacts = [];
        _currentScreen = CurrentScreen.PlaceolderImage;
        _welcomeScreenProvider.isSelectionItemChanged = false;
        notes = null;
        _notesController.clear();
      });
    }
  }

  reAttemptSendingFiles() async {
    if (mounted) {
      setState(() {
        isFileShareFailed = false;
        isFileSending = true;
        _filePickerProvider.updateFileSendingStatus(true);
      });
    }

    // when entry is not added in sent history.
    if (!isSentFileEntrySaved) {
      sendFileWithFileBin();
      return;
    }

    // when entry is added in sent history but notifications didn't go through.
    var res = await _filePickerProvider.reAttemptInSendingFiles();

    if (!res) {
      SnackbarService().showSnackbar(
        context,
        TextStrings().oopsSomethingWentWrong,
        bgColor: ColorConstants.redAlert,
      );
      if (mounted) {
        setState(() {
          isFileShareFailed = true;
        });
      }
    }

    if (mounted) {
      setState(() {
        isFileSending = false;
        _filePickerProvider.updateFileSendingStatus(false);
      });
    }
  }

  sendFileWithFileBin() async {
    _filePickerProvider.updateFileSendingStatus(true);
    if (mounted) {
      setState(() {
        // assuming file share record will be saved in sent history.
        isSentFileEntrySaved = true;
        isFileShareFailed = false;
        isFileSending = true;
      });
    }
    _welcomeScreenProvider.resetSelectedContactsStatus();
    _filePickerProvider.resetSelectedFilesStatus();

    var res = await _filePickerProvider.sendFileWithFileBin(
      _filePickerProvider.selectedFiles,
      _welcomeScreenProvider.selectedContacts,
      groupName: _welcomeScreenProvider.groupName,
      notes: notes,
    );

    if (mounted && res is bool) {
      setState(() {
        isFileShareFailed = !res;
      });

      if (!isFileShareFailed) {
        SnackbarService().showSnackbar(
          context,
          TextStrings().fileSentSuccessfully,
          bgColor: Color(0xFF5FAA45),
        );
        _welcomeScreenProvider.isSelectionItemChanged = false;
      } else {
        SnackbarService().showSnackbar(
          context,
          TextStrings().oopsSomethingWentWrong,
          bgColor: ColorConstants.redAlert,
        );
      }
    } else if (res == null) {
      SnackbarService().showSnackbar(
        context,
        TextStrings().oopsSomethingWentWrong,
        bgColor: ColorConstants.redAlert,
      );

      if (mounted) {
        setState(() {
          isFileShareFailed = true;
          isSentFileEntrySaved = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _filePickerProvider.updateFileSendingStatus(false);
        isFileSending = false;
      });
    }
  }
}
