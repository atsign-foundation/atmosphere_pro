///This is a custom app bar [showTitle] enables to display the title in the center
///[showBackButton] toggles the automatically implies leading functionality
///if [false] it shows a [Close] String instead of backbutton
///[showLeadingButton] toggles the drawer menu button
///[title] is a [String] to display the title of the appbar
///[showTrailingButton] toggles the visibility of trailing button, default add icon
///therefore it has it's navigation embedded in the widget itself.

import 'dart:io';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showTitle;
  final bool showBackButton;
  final bool showLeadingicon;
  final bool showTrailingButton;
  final IconData trailingIcon;
  final bool isHistory;
  final onActionpressed;
  final bool isTrustedContactScreen;
  final double elevation;
  const CustomAppBar(
      {Key key,
      this.title,
      this.showTitle = false,
      this.showBackButton = false,
      this.showLeadingicon = false,
      this.showTrailingButton = false,
      this.trailingIcon = Icons.add,
      this.isHistory = false,
      this.elevation = 0,
      this.onActionpressed,
      this.isTrustedContactScreen = false})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  HistoryProvider historyProvider;
  FileTransfer receivedHistory;
  bool isDownloadAvailable = false, isFilesAvailableOfline = true;

  @override
  void didChangeDependencies() async {
    if (historyProvider == null) {
      historyProvider = Provider.of<HistoryProvider>(context);
    }
    historyProvider.receivedHistoryLogs.forEach((value) {
      receivedHistory = value;
      checkForDownloadAvailability();
      isFilesAlreadyDownloaded();
    });
    super.didChangeDependencies();
  }

  checkForDownloadAvailability() {
    var expiryDate = receivedHistory.date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    var isFileUploaded = false;
    receivedHistory.files.forEach((FileData fileData) {
      if (fileData.isUploaded) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      isDownloadAvailable = false;
    }
  }

  isFilesAlreadyDownloaded() async {
    receivedHistory.files.forEach((element) async {
      String path = BackendService.getInstance().downloadDirectory.path +
          '/${element.name}';
      File test = File(path);
      bool fileExists = await test.exists();
      if (fileExists == false) {
        setState(() {
          isFilesAvailableOfline = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: widget.elevation ?? 0,
      centerTitle: true,
      leading: (widget.showLeadingicon)
          ? Image.asset(ImageConstants.logoIcon)
          : (widget.showBackButton)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.fontPrimary,
                    size: 25.toFont,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : null,
      title: Row(
        children: [
          Container(
            height: 40.toHeight,
            margin: EdgeInsets.only(top: 5.toHeight),
            child: (!widget.showBackButton && !widget.showLeadingicon)
                ? Center(
                    child: GestureDetector(
                      child: Text(
                        TextStrings().buttonClose,
                        style: CustomTextStyles.blueRegular18,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: (widget.showTitle)
                ? Center(
                    child: Text(
                      widget.title,
                      style: CustomTextStyles.primaryBold18,
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      actions: [
        Container(
          height: 22.toHeight,
          width: 22.toWidth,
          margin: EdgeInsets.only(right: 30),
          child: (widget.showTitle)
              ? (widget.showTrailingButton)
                  ? IconButton(
                      icon: Icon(
                        widget.trailingIcon,
                        size: 25.toFont,
                      ),
                      onPressed: () async {
                        if (widget.isHistory) {
                          // navigate to downloads folder
                          if (Platform.isAndroid) {
                            await FilesystemPicker.open(
                              title: 'Atmosphere download folder',
                              context: context,
                              rootDirectory: BackendService.getInstance()
                                  .downloadDirectory,
                              fsType: FilesystemType.all,
                              folderIconColor: Colors.teal,
                              allowedExtensions: [],
                              fileTileSelectMode: FileTileSelectMode.wholeTile,
                              requestPermission: () async =>
                                  await Permission.storage.request().isGranted,
                            );
                          } else {
                            String url = 'shareddocuments://' +
                                BackendService.getInstance()
                                    .atClientPreference
                                    .downloadPath;
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
                        } else if (widget.isTrustedContactScreen) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactsScreen(
                                asSelectionScreen: true,
                                context: NavService.navKey.currentContext,
                                selectedList: (s) async {
                                  s.forEach((element) async {
                                    await Provider.of<TrustedContactProvider>(
                                            context,
                                            listen: false)
                                        .addTrustedContacts(element);
                                  });
                                  await Provider.of<TrustedContactProvider>(
                                          context,
                                          listen: false)
                                      .setTrustedContact();
                                },
                              ),
                            ),
                          );
                        } else {
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => AddContactDialog(
                                // onYesTap: (value) {
                                //   onActionpressed(value);
                                // },
                                ),
                          );
                        }
                      })
                  : Container()
              : GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: isDownloadAvailable && !isFilesAvailableOfline
                      ? Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10.toHeight),
                              height: 22.toHeight,
                              width: 22.toWidth,
                              child: Image.asset(
                                ImageConstants.drawerIcon,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.toHeight),
                              child: CircleAvatar(
                                backgroundColor: ColorConstants.orangeColor,
                                radius: 5.toWidth,
                              ),
                            ),
                          ],
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 10.toHeight),
                          height: 22.toHeight,
                          width: 22.toWidth,
                          child: Image.asset(
                            ImageConstants.drawerIcon,
                          ),
                        )),
        )
      ],
      automaticallyImplyLeading: false,
      backgroundColor: ColorConstants.appBarColor,
    );
  }
}
