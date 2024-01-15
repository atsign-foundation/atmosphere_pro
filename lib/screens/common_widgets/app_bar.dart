///This is a custom app bar [showTitle] enables to display the title in the center
///[showBackButton] toggles the automatically implies leading functionality
///if [false] it shows a [Close] String instead of backbutton
///[showLeadingButton] toggles the drawer menu button
///[title] is a [String] to display the title of the appbar
///[showTrailingButton] toggles the visibility of trailing button, default add icon
///therefore it has it's navigation embedded in the widget itself.
import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showTitle;
  final bool showBackButton;
  final bool showLeadingIcon;
  final bool showTrailingButton;
  final bool showMenu;
  final bool showClosedBtnText;
  final IconData trailingIcon;
  final bool isHistory;
  final onActionPressed;
  final bool isTrustedContactScreen;
  final double elevation;

  const CustomAppBar(
      {Key? key,
      this.title,
      this.showTitle = false,
      this.showBackButton = false,
      this.showLeadingIcon = false,
      this.showTrailingButton = false,
      this.showClosedBtnText = true,
      this.showMenu = false,
      this.trailingIcon = Icons.add,
      this.isHistory = false,
      this.elevation = 0,
      this.onActionPressed,
      this.isTrustedContactScreen = false})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: widget.elevation,
      centerTitle: false,
      leading: (widget.showLeadingIcon)
          ? Image.asset(ImageConstants.logoIcon)
          : (widget.showBackButton)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.fontPrimary,
                    size: 25.toFont,
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    }
                  })
              : null,
      title: Row(
        children: [
          Container(
            height: 40.toHeight,
            margin: EdgeInsets.only(top: 5.toHeight),
            child: (!widget.showBackButton &&
                    !widget.showLeadingIcon &&
                    widget.showClosedBtnText)
                ? Center(
                    child: GestureDetector(
                      child: Text(
                        TextStrings().buttonClose,
                        style: CustomTextStyles.blueRegular18,
                      ),
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: (widget.showTitle)
                ? Text(
                    widget.title!,
                    style: CustomTextStyles.blackBold25,
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
              ? ((widget.showTrailingButton)
                  ? widget.showMenu
                      ? menuBar(context)
                      : IconButton(
                          icon: Icon(
                            widget.trailingIcon,
                            size: 25.toFont,
                            color: ColorConstants.blueText,
                          ),
                          onPressed: () async {
                            if (widget.isHistory) {
                              // navigate to downloads folder
                              if (Platform.isAndroid) {
                                await FilesystemPicker.open(
                                  title: 'Atmosphere download folder',
                                  context: context,
                                  rootDirectory: BackendService.getInstance()
                                      .downloadDirectory!,
                                  fsType: FilesystemType.all,
                                  folderIconColor: Colors.teal,
                                  allowedExtensions: [],
                                  fileTileSelectMode:
                                      FileTileSelectMode.wholeTile,
                                  requestPermission: () async =>
                                      await Permission.storage
                                          .request()
                                          .isGranted,
                                );
                              } else {
                                final path = 'shareddocuments://' +
                                    BackendService.getInstance()
                                        .atClientPreference
                                        .downloadPath!;
                                final url = Uri.parse(path);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
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
                                    selectedContactsHistory: [],
                                    selectedList: (s) async {
                                      for (var element in s) {
                                        await Provider.of<
                                                    TrustedContactProvider>(
                                                context,
                                                listen: false)
                                            .addTrustedContacts(element!);
                                      }
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
                  : Container())
              : menuBar(context),
        )
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget menuBar(BuildContext context) {
    return Consumer<FileDownloadChecker>(
      builder: (context, _fileDownloadChecker, _) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          alignment: Alignment.topCenter,
          tooltip: _fileDownloadChecker.unDownloadedFilesExist
              ? 'Hamburger Menu & Dot'
              : 'Hamburger Menu',
          padding: EdgeInsets.zero,
          icon: Stack(
            alignment: Alignment.topRight,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.toHeight),
                height: 22.toHeight,
                width: 22.toWidth,
                child: Image.asset(
                  ImageConstants.drawerIcon,
                  semanticLabel: '',
                ),
              ),
              _fileDownloadChecker.unDownloadedFilesExist
                  ? Positioned(
                      right: -4,
                      top: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(1.toHeight),
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 5.toWidth,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
