import 'dart:io';
import 'dart:typed_data';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class SentFilesListTile extends StatefulWidget {
  final FileHistory? sentHistory;

  const SentFilesListTile({
    Key? key,
    this.sentHistory,
  }) : super(key: key);
  @override
  _SentFilesListTileState createState() => _SentFilesListTileState();
}

class _SentFilesListTileState extends State<SentFilesListTile> {
  int fileSize = 0;
  List<FileData> filesList = [];
  List<String> contactList, displayName, nickName;
  bool isOpen = false;
  bool isDeepOpen = false;
  Uint8List? videoThumbnail, firstContactImage;

  List<bool> fileResending = [];
  bool isResendingToFirstContact = false;

  @override
  void initState() {
    super.initState();
                                  height: 45.toHeight,
                                        )
                              ),
                                      child: Container(
                                        ),
                                  ? Positioned(
                                        },
                                        child: Container(
                                          height: 35.toHeight,
                                          width: 35.toHeight,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50.toWidth),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5)),
                                          child: Center(
                                            child: contactList.length > 1
                                                ? Text(
                                                    '+${contactList.length - 1}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.toFont))
                                                : Icon(Icons.download_done,
                                                    color: Colors.white,
                                                    size: 15),
                                          ),
                                        ),
                                      ))
                                  : SizedBox()
                            ],
                          ),
                  )
                : SizedBox(),
            title: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: displayName.isNotEmpty
                            ? RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '${displayName[0]} ',
                                    style: CustomTextStyles.primaryRegular16,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        openFileReceiptBottomSheet();
                                      },
