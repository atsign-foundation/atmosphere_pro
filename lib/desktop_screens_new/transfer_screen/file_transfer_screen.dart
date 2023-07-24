import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/widgets/add_contact_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/widgets/add_file_tile.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:dotted_border/dotted_border.dart';
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

  var isSentFileEntrySaved;
  var isFileShareFailed;
  var isFileSending;

  var filteredContactList = [];

  @override
  void initState() {
    super.initState();
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);

    messageController = TextEditingController(text: "");
    searchController = TextEditingController(text: "");
    filteredContactList.addAll(ContactService().contactList);
  }

  List<GroupContactsModel> selectedContacts = [];

  void addSelectedContact(AtContact contact) {
    var groupContact = GroupContactsModel(contact: contact);
    if (selectedContacts.contains(groupContact)) {
      selectedContacts.remove(groupContact);
    } else {
      selectedContacts.add(groupContact);
    }
  }

  sendFileWithFileBin(List<GroupContactsModel> contactList) async {
    _filePickerProvider.updateFileSendingStatus(true);
    if (mounted) {
      setState(() {
        // assuming file share record will be saved in sent history.
        isSentFileEntrySaved = true;
        isFileShareFailed = false;
        isFileSending = true;
      });
    }
    // _filePickerProvider.resetSelectedContactsStatus();
    // _filePickerProvider.resetSelectedFilesStatus();

    var res = await _filePickerProvider.sendFileWithFileBin(
      _filePickerProvider.selectedFiles,
      contactList,
      notes: messageController.text,
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
        // _welcomeScreenProvider.isSelectionItemChanged = false;
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

  @override
  Widget build(BuildContext context) {
    var selectedFiles = context.watch<FileTransferProvider>().selectedFiles;
    var contactList = context.watch<FileTransferProvider>().selectedContacts;

    List<AtContact> trustedContacts =
        context.read<TrustedContactProvider>().trustedContacts;
    SizeConfig().init(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 40, top: 30, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transfer File",
              style: TextStyle(
                fontSize: 24.toFont,
                fontWeight: FontWeight.bold,
              ),
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
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Wrap(
                children: selectedFiles.map((file) {
                  return AddFileTile(file: file);
                }).toList(),
              ),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            InkWell(
              onTap: () async {
                var files = await desktopImagePicker();
                if (files != null) {
                  _filePickerProvider.selectedFiles.add(files[0]);
                  _filePickerProvider.notify();
                }
                print("selected files: $files");
              },
              child: selectedFiles.isEmpty
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
                                  fontSize: 20.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 10.toHeight,
                              ),
                              Text(
                                "Drag or drop files or Browse",
                                style: TextStyle(
                                  color: ColorConstants.gray,
                                  fontSize: 15.toFont,
                                ),
                              ),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add Files (Drag or Drop Files)",
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
            SizedBox(
              height: 30.toHeight,
            ),
            selectedContacts.isNotEmpty
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
                    itemCount: selectedContacts.length,
                    itemBuilder: (context, index) {
                      var contact = selectedContacts[index];
                      var isTrusted = false;
                      for (var ts in trustedContacts) {
                        if (ts.atSign == (contact.contact?.atSign ?? "")) {
                          isTrusted = true;
                        }
                      }
                      Uint8List? byteImage =
                          CommonUtilityFunctions().getCachedContactImage(
                        contact.contact!.atSign!,
                      );
                      return Container(
                        height: 70,
                        child: AddContactTile(
                          title: selectedContacts[index].contact?.atSign,
                          subTitle: selectedContacts[index]
                                  .contact
                                  ?.tags?["nickname"] ??
                              selectedContacts[index].contact?.atSign,
                          image: byteImage,
                          showImage: byteImage != null,
                          hasBackground: true,
                          isTrusted: isTrusted,
                        ),
                      );
                    },
                  )
                : SizedBox(),
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
                        "Add atsigns",
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
              height: 30.toHeight,
            ),
            InkWell(
              onTap: () async {
                await sendFileWithFileBin(contactList);
              },
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedFiles.isNotEmpty
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    "Transfer Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.toHeight,
            ),
          ],
        ),
      ),
    );
  }

  void showAtSignDialog(List<AtContact> trustedContacts) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          if (searchController.text.isEmpty && filteredContactList.isEmpty) {
            filteredContactList = [...ContactService().contactList];
            setDialogState(() {});
          }

          return Dialog(
            insetPadding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            elevation: 5.0,
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              width: 400.toWidth,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Add atSigns",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
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
                                      in ContactService().contactList) {
                                    if (contact.atSign!.contains(value)) {
                                      filteredContactList.add(contact);
                                    }
                                  }
                                  setDialogState(() {});
                                },
                                controller: searchController,
                                decoration: InputDecoration(
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
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: ColorConstants.MILD_GREY,
                              child: Icon(
                                Icons.verified_outlined,
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // contact list
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredContactList.length,
                        itemBuilder: (context, index) {
                          var contact = filteredContactList[index];
                          var isTrusted = false;
                          for (var ts in trustedContacts) {
                            if (ts.atSign == (contact.atSign)) {
                              isTrusted = true;
                            }
                          }

                          Uint8List? byteImage =
                              CommonUtilityFunctions().getCachedContactImage(
                            contact.atSign!,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15, top: 5, bottom: 5),
                            child: InkWell(
                              onTap: () {
                                addSelectedContact(contact);
                                setDialogState(() {});
                              },
                              child: AddContactTile(
                                title: contact.atSign,
                                subTitle:
                                    contact.tags?["nickname"] ?? contact.atSign,
                                image: byteImage,
                                showImage: byteImage != null,
                                isSelected: selectedContacts.contains(
                                    GroupContactsModel(contact: contact)),
                                showDivider: true,
                                isTrusted: isTrusted,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        margin: EdgeInsets.only(bottom: 20),
                        width: double.maxFinite,
                        child: Text(
                          "Add atSigns   ${selectedContacts.length}",
                          style: TextStyle(
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
}
