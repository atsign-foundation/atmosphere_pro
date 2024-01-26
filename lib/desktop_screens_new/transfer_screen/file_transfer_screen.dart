import 'dart:async';
import 'dart:io';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/common_widgets/file_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/notification_icon.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/widgets/add_atsigns_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/widgets/add_contact_tile.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({Key? key}) : super(key: key);

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  late FileTransferProvider _filePickerProvider;
  late TextEditingController messageController;
  late TextEditingController searchController;
  bool showFileSentCard = false;

  var isSentFileEntrySaved;
  var isFileShareFailed = false;
  bool isFileSending = false;
  String initialLetter = "";

  List<GroupContactsModel?> filteredContactList = [];

  @override
  void initState() {
    super.initState();
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);

    messageController = TextEditingController(text: "");
    searchController = TextEditingController(text: "");
    filteredContactList.addAll(GroupService().allContacts);
    GroupService().fetchGroupsAndContacts();
  }

  List<GroupContactsModel> selectedContacts = [];

  sendFileWithFileBin(List<GroupContactsModel> contactList) async {
    bool isFilesReady = true;
    for (int i = 0; i < _filePickerProvider.selectedFiles.length; i++) {
      final isExist =
          File(_filePickerProvider.selectedFiles[i].path ?? '').existsSync();
      if (!isExist) {
        _filePickerProvider.deleteFiles(i);
        isFilesReady = false;
      }
    }

    if (!isFilesReady) {
      SnackbarService().showSnackbar(
        context,
        'File(s) not found and removed',
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

    setState(() {
      showFileSentCard = false;
    });
    _filePickerProvider.updateFileSendingStatus(true);
    if (mounted) {
      setState(() {
        // assuming file share record will be saved in sent history.
        isSentFileEntrySaved = true;
        isFileShareFailed = false;
        isFileSending = true;
      });
    }

    var res = await _filePickerProvider.sendFileWithFileBin(
      _filePickerProvider.selectedFiles,
      contactList,
      notes: messageController.text,
    );

    if (mounted && res is bool) {
      setState(() {
        isFileShareFailed = !res;
        showFileSentCard = true;
      });

      if (!isFileShareFailed) {
        SnackbarService().showSnackbar(
          context,
          TextStrings().fileSentSuccessfully,
          bgColor: Color(0xFF5FAA45),
        );
        messageController.clear();
        _filePickerProvider.selectedContacts.clear();
        _filePickerProvider.selectedFiles.clear();
        _filePickerProvider.notify();
      } else {
        SnackbarService().showSnackbar(
          context,
          TextStrings().oopsSomethingWentWrong,
          bgColor: ColorConstants.redAlert,
        );
        await showRetrySending();
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

  Future<void> showRetrySending() async {
    await context.read<InternetConnectivityChecker>().checkConnectivity();
    final bool isInternetAvailable =
        context.read<InternetConnectivityChecker>().isInternetAvailable;
    if (isInternetAvailable) {
      await openFileReceiptBottomSheet();
    } else {
      Timer.periodic(Duration(seconds: 5), (timer) async {
        await context.read<InternetConnectivityChecker>().checkConnectivity();
        final bool isInternetAvailable =
            context.read<InternetConnectivityChecker>().isInternetAvailable;
        if (isInternetAvailable) {
          timer.cancel();
          await openFileReceiptBottomSheet();
        }
      });
    }
  }

  openFileReceiptBottomSheet(
      {FileRecipientSection? fileRecipientSection}) async {
    await Provider.of<HistoryProvider>(context, listen: false).getSentHistory();
    final List<FileHistory> sentList =
        Provider.of<HistoryProvider>(context, listen: false).sentHistory;
    _filePickerProvider.selectedFileHistory = sentList[0];

    if (!(sentList[0].fileDetails?.files ?? [])
        .any((element) => element.isUploaded == false)) {
      await showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (_context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Dialog(
                  insetPadding: EdgeInsets.zero,
                  alignment: Alignment.centerRight,
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    width: 400,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12.0),
                        topRight: const Radius.circular(12.0),
                      ),
                    ),
                    child: FileRecipients(
                      sentList[0].sharedWith,
                      fileRecipientSection: fileRecipientSection,
                      key: UniqueKey(),
                    ),
                  ),
                );
              },
            );
          }).then((value) {
        messageController.clear();
        _filePickerProvider.resetData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AtContact> trustedContacts =
        context.read<TrustedContactProvider>().trustedContacts;
    SizeConfig().init(context);

    return Consumer<FileTransferProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, top: 30, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transfer File",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  NotificationIcon()
                ],
              ),
              SizedBox(height: 10),
              const Divider(
                thickness: 1,
                color: Colors.black,
              ),
              SizedBox(height: 20),
              Text(
                "SELECT FILES",
                style: TextStyle(
                  color: ColorConstants.gray,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropTarget(
                onDragDone: (details) async {
                  await Future.forEach(details.files, (XFile f) async {
                    _filePickerProvider.selectedFiles.add(
                      PlatformFile(
                        path: f.path,
                        name: f.name,
                        size: await f.length(),
                      ),
                    );
                  });
                  _filePickerProvider.notify();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Wrap(
                        children: provider.selectedFiles.map((file) {
                          return Stack(
                            children: [
                              FileTile(
                                key: UniqueKey(),
                                fileName: file.name,
                                fileExt: file.name.split(".").last,
                                filePath: file.path ?? "",
                                fileSize: file.size.toDouble(),
                                fileDate: DateTime.now().toString(),
                                id: null,
                              ),
                              Positioned(
                                right: 20,
                                top: 20,
                                child: InkWell(
                                  onTap: () {
                                    var index =
                                        provider.selectedFiles.indexOf(file);
                                    context
                                        .read<FileTransferProvider>()
                                        .deleteFiles(index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.clear,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10.toHeight,
                    ),
                    InkWell(
                      onTap: () async {
                        var files = await desktopImagePicker();
                        if (files != null && files.isNotEmpty) {
                          _filePickerProvider.selectedFiles.addAll(files);
                          _filePickerProvider.notify();
                        }
                      },
                      child: provider.selectedFiles.isEmpty
                          ? DottedBorder(
                              color: Theme.of(context).primaryColor,
                              padding: EdgeInsets.zero,
                              dashPattern: [6, 4],
                              strokeWidth: 1.5,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: ColorConstants.orangeColorDim,
                                    borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: FractionallySizedBox(
                                  widthFactor: 0.7,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        ImageConstants.uploadFile,
                                        height: 60.toHeight,
                                      ),
                                      SizedBox(
                                        height: 10.toHeight,
                                      ),
                                      Text(
                                        "Upload your File(s)",
                                        style: TextStyle(
                                          fontSize: 15.toFont,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Drag and drop files or Browse",
                                        style: TextStyle(
                                          color: ColorConstants.greyTextColor,
                                          fontSize: 12.toFont,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.toHeight,
                                      ),
                                      // Text(
                                      //   "Drag or drop files or Browse",
                                      //   style: TextStyle(
                                      //     color: ColorConstants.gray,
                                      //     fontSize: 15.toFont,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : FractionallySizedBox(
                              widthFactor: 0.7,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorConstants.yellowDim,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Add Files",
                                      style: TextStyle(
                                        color: ColorConstants.yellow,
                                        fontSize: 16.toFont,
                                      ),
                                    ),
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: ColorConstants.yellow,
                                      size: 25,
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.toHeight,
              ),
              Text(
                "SELECT CONTACTS",
                style: TextStyle(
                  color: ColorConstants.gray,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              provider.selectedContacts.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // number of items per row
                        crossAxisCount: 3,
                        mainAxisSpacing: 0,
                        // horizontal spacing between the items
                        crossAxisSpacing: 30,
                        mainAxisExtent: 80,
                      ),
                      itemCount: provider.selectedContacts.length,
                      itemBuilder: (context, index) {
                        var groupContactModel =
                            provider.selectedContacts[index];
                        late var contact;
                        var isTrusted;
                        var byteImage;
                        if (groupContactModel.contactType ==
                            ContactsType.CONTACT) {
                          contact = groupContactModel.contact;
                          isTrusted = false;
                          for (var ts in trustedContacts) {
                            if (ts.atSign == (contact?.atSign ?? "")) {
                              isTrusted = true;
                            }
                          }
                          byteImage =
                              CommonUtilityFunctions().getCachedContactImage(
                            (contact?.atSign ?? ""),
                          );
                        }
                        return Container(
                          height: 70,
                          child: groupContactModel.contactType ==
                                  ContactsType.CONTACT
                              ? AddContactTile(
                                  title: provider
                                      .selectedContacts[index].contact?.atSign,
                                  subTitle: provider.selectedContacts[index]
                                      .contact?.tags?["nickname"],
                                  image: byteImage,
                                  showImage: byteImage != null,
                                  hasBackground: true,
                                  isTrusted: isTrusted,
                                  index: index,
                                )
                              : AddContactTile(
                                  title: groupContactModel.group?.groupName,
                                  subTitle:
                                      '${groupContactModel.group?.members?.length} member(s)',
                                  image: byteImage,
                                  showImage: byteImage != null,
                                  hasBackground: true,
                                  isTrusted: false,
                                  index: index,
                                ),
                        );
                      },
                    )
                  : SizedBox(),
              InkWell(
                onTap: () {
                  showAtSignDialog(trustedContacts);
                },
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.orangeColorDim,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Contacts or Groups",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16.toFont,
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                          size: 25,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Send Message (Optional)",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20)),
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              showFileSentCard
                  ? FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Card(
                        color: isFileShareFailed
                            ? Colors.red.shade300
                            : Colors.green.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  isFileShareFailed
                                      ? "Failed to send file(s)"
                                      : "Sent successfully",
                                  style: TextStyle(color: Colors.white)),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    showFileSentCard = false;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 30.toHeight,
              ),
              Consumer<FileProgressProvider>(builder: (context, value, child) {
                String text = _getText(
                  fileTransferProgress: value.sentFileTransferProgress,
                );
                return InkWell(
                  onTap: isFileSending
                      ? null
                      : () async {
                          if (isFileSending == false) {
                            await sendFileWithFileBin(
                                provider.selectedContacts);
                          }
                        },
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: provider.selectedFiles.isNotEmpty
                            ? LinearGradient(
                                colors: [
                                  Color.fromRGBO(240, 94, 63, 1),
                                  Color.fromRGBO(234, 167, 67, 0.65),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Color.fromRGBO(216, 216, 216, 1),
                                  Color.fromRGBO(216, 216, 216, 1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Text(
                        isFileSending == true ? text : "Transfer Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 30.toHeight,
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getText({FileTransferProgress? fileTransferProgress}) {
    if (fileTransferProgress?.fileState == FileState.encrypt) {
      return 'Encrypting...';
    } else {
      return 'Sending...';
    }
  }

  void showAtSignDialog(List<AtContact> trustedContacts) async {
    await GroupService().fetchGroupsAndContacts(isDesktop: true);
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return AddAtSignsWidget(
          trustedContacts: trustedContacts,
          selectedContacts: selectedContacts,
          addSelectedContactList: (value) {
            selectedContacts = value;
            context.read<FileTransferProvider>().selectedContacts =
                selectedContacts;
            context.read<FileTransferProvider>().notify();
          },
        );
      },
    );
  }
}
