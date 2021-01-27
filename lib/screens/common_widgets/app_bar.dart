///This is a custom app bar [showTitle] enables to display the title in the center
///[showBackButton] toggles the automatically implies leading functionality
///if [false] it shows a [Close] String instead of backbutton
///[showLeadingButton] toggles the drawer menu button
///[title] is a [String] to display the title of the appbar
///[showTrailingButton] toggles the visibility of trailing button, default add icon
///therefore it has it's navigation embedded in the widget itself.

import 'dart:io';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/contact/widgets/add_contact_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/group_contact_screen.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
      {this.title,
      this.showTitle = false,
      this.showBackButton = false,
      this.showLeadingicon = false,
      this.showTrailingButton = false,
      this.trailingIcon = Icons.add,
      this.isHistory = false,
      this.elevation = 0,
      this.onActionpressed,
      this.isTrustedContactScreen = false});
  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 0,
      centerTitle: true,
      leading: (showLeadingicon)
          ? Image.asset(ImageConstants.logoIcon)
          : (showBackButton)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.fontPrimary,
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
            child: (!showBackButton && !showLeadingicon)
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
            child: (showTitle)
                ? Center(
                    child: Text(
                      title,
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
          margin: EdgeInsets.only(right: 20),
          child: (showTitle)
              ? (showTrailingButton)
                  ? IconButton(
                      icon: Icon(trailingIcon),
                      onPressed: () async {
                        if (isHistory) {
                          // navigate to downloads folder
                          if (Platform.isAndroid) {
                            String path = await FilesystemPicker.open(
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
                        } else if (isTrustedContactScreen) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupContactScreen(
                                isTrustedScreen: true,
                              ),
                            ),
                          );
                        } else {
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => AddContactDialog(
                              onYesTap: (value) {
                                onActionpressed(value);
                              },
                            ),
                          );
                        }
                      })
                  : Container()
              : GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    height: 22.toHeight,
                    width: 22.toWidth,
                    child: Image.asset(
                      ImageConstants.drawerIcon,
                    ),
                  ),
                ),
        )
      ],
      automaticallyImplyLeading: false,
      backgroundColor: ColorConstants.appBarColor,
    );
  }
}
