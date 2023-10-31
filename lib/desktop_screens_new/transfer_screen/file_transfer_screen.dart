import 'dart:async';
import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/common_widgets/file_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/notification_icon.dart';
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

  bool isSentFileEntrySaved = false;
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

  void addSelectedContact(GroupContactsModel contact) {
    if (isSelected(contact)) {
      selectedContacts.removeWhere((element) => element == contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  sendFileWithFileBin(List<GroupContactsModel> contactList) async {
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
          bgColor: const Color(0xFF5FAA45),
        );
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
      Timer.periodic(const Duration(seconds: 5), (timer) async {
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
        .any((element) => element.isUploaded == false) && mounted) {
      await showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (context) {
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
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
          }).then((value) => _filePickerProvider.resetData());
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
              const Row(
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
              const SizedBox(height: 10),
              const Divider(
                thickness: 1,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
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
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
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
                              dashPattern: const [6, 4],
                              strokeWidth: 1.5,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: ColorConstants.orangeColorDim,
                                    borderRadius: BorderRadius.circular(5)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
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
                                padding: const EdgeInsets.symmetric(
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
                                    const Icon(
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
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                        late AtContact? contact;
                        late bool isTrusted;
                        Uint8List? byteImage;
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
                        return SizedBox(
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
                                      '${groupContactModel.group?.members?.length} members',
                                  image: byteImage,
                                  showImage: byteImage != null,
                                  hasBackground: true,
                                  isTrusted: false,
                                  index: index,
                                ),
                        );
                      },
                    )
                  : const SizedBox(),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add atSigns",
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
                    decoration: const InputDecoration(
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
                                  style: const TextStyle(color: Colors.white)),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    showFileSentCard = false;
                                  });
                                },
                                child: const Icon(
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
                  : const SizedBox(),
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
                            ? const LinearGradient(
                                colors: [
                                  Color.fromRGBO(240, 94, 63, 1),
                                  Color.fromRGBO(234, 167, 67, 0.65),
                                ],
                              )
                            : const LinearGradient(
                                colors: [
                                  Color.fromRGBO(216, 216, 216, 1),
                                  Color.fromRGBO(216, 216, 216, 1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Text(
                        isFileSending == true ? text : "Transfer Now",
                        style: const TextStyle(
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
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          if (searchController.text.isEmpty && filteredContactList.isEmpty) {
            filteredContactList = [...GroupService().allContacts];
            setDialogState(() {});
          }

          return Dialog(
            insetPadding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            elevation: 5.0,
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              width: 400.toWidth,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Add atSigns",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    filteredContactList = [];
                                    for (var contact
                                        in GroupService().allContacts) {
                                      if (contact?.contactType ==
                                          ContactsType.CONTACT) {
                                        if ((contact?.contact?.atSign
                                                ?.contains(value)) ??
                                            false) {
                                          filteredContactList.add(contact);
                                        }
                                      } else if (contact?.contactType ==
                                          ContactsType.GROUP) {
                                        if ((contact?.group?.groupName
                                                ?.contains(value)) ??
                                            false) {
                                          filteredContactList.add(contact);
                                        }
                                      }
                                    }
                                    setDialogState(() {});
                                  },
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    hintText: "Search...",
                                    suffixIcon: Icon(
                                      Icons.search,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // InkWell(
                            //   onTap: () {},
                            //   child: CircleAvatar(
                            //     backgroundColor: ColorConstants.MILD_GREY,
                            //     child: Icon(
                            //       Icons.verified_outlined,
                            //       size: 25,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // contact list
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredContactList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var groupContactModel = filteredContactList[index];
                            late AtContact contact;
                            var isTrusted = false;
                            Uint8List? byteImage;

                            if (groupContactModel?.contactType ==
                                ContactsType.CONTACT) {
                              contact = groupContactModel!.contact!;
                              for (var ts in trustedContacts) {
                                if (ts.atSign == (contact.atSign)) {
                                  isTrusted = true;
                                }
                              }
                              if (initialLetter != contact.atSign?[1]) {
                                initialLetter = contact.atSign?[1] ?? "";
                              } else {
                                initialLetter = "";
                              }
                              byteImage = CommonUtilityFunctions()
                                  .getCachedContactImage(
                                contact.atSign!,
                              );
                            } else {
                              if ((groupContactModel
                                          ?.group?.groupName?.isNotEmpty ??
                                      false) &&
                                  initialLetter !=
                                      groupContactModel?.group?.groupName?[0]) {
                                initialLetter =
                                    groupContactModel?.group?.groupName?[0] ??
                                        "";
                              } else {
                                initialLetter = "";
                              }
                            }

                            return Column(
                              children: [
                                initialLetter.isNotEmpty
                                    ? Row(
                                        children: [
                                          Text(
                                            initialLetter,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFF717171),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          const Expanded(
                                            child: Divider(
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 5, bottom: 5),
                                  child: InkWell(
                                    onTap: () {
                                      addSelectedContact(groupContactModel!);
                                      setDialogState(() {});
                                    },
                                    child: groupContactModel?.contactType ==
                                            ContactsType.CONTACT
                                        ? AddContactTile(
                                            title: contact.atSign,
                                            subTitle: contact.tags?["nickname"],
                                            image: byteImage,
                                            showImage: byteImage != null,
                                            isSelected:
                                                isSelected(groupContactModel!),
                                            showDivider: true,
                                            isTrusted: isTrusted,
                                          )
                                        : AddContactTile(
                                            title: groupContactModel
                                                ?.group?.groupName,
                                            subTitle:
                                                '${groupContactModel?.group?.members?.length} members',
                                            image: byteImage,
                                            showImage: byteImage != null,
                                            isSelected:
                                                isSelected(groupContactModel!),
                                            showDivider: true,
                                            isTrusted: false,
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        context.read<FileTransferProvider>().selectedContacts =
                            selectedContacts;
                        context.read<FileTransferProvider>().notify();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsets.only(bottom: 20),
                        width: double.maxFinite,
                        child: Text(
                          "Add atSigns ${selectedContacts.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  bool isSelected(GroupContactsModel groupContactsModel) {
    for (GroupContactsModel contact in selectedContacts) {
      if ((groupContactsModel.contactType == ContactsType.CONTACT &&
              contact.contact == groupContactsModel.contact) ||
          (groupContactsModel.contactType == ContactsType.GROUP &&
              contact.group == groupContactsModel.group)) {
        return true;
      }
    }
    return false;
  }
}
