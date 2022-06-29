import 'dart:io';

import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/backend_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class HistoryAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  HistoryAppBar({required this.title});

  @override
  _HistoryAppBarState createState() => _HistoryAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);
}

class _HistoryAppBarState extends State<HistoryAppBar> {
  late HistoryProvider _historyProvider;
  bool _showSearchField = false;

  @override
  void initState() {
    _historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _historyProvider.setHistorySearchText = '';
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ColorConstants.fontPrimary,
          size: 25.toFont,
        ),
        onPressed: () {
          if (_showSearchField) {
            setState(() {
              _showSearchField = false;
            });

            return;
          }
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
        },
      ),
      title: !_showSearchField
          ? Text(
              widget.title,
              style: CustomTextStyles.primaryBold18,
            )
          : Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    hintText: 'Search history by atsign',
                    initialValue: _historyProvider.getSearchText,
                    icon: Icons.search,
                    value: (String txt) {
                      _historyProvider.setHistorySearchText = txt;
                    },
                    onSubmitted: (String txt) {
                      _historyProvider.setHistorySearchText = txt;
                    },
                  ),
                ),
              ],
            ),
      actions: _showSearchField
          ? null
          : [
              Container(
                height: 22.toHeight,
                width: 22.toWidth,
                margin: EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearchField = true;
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    size: 25.toFont,
                    color: ColorConstants.blueText,
                  ),
                ),
              ),
              Container(
                height: 22.toHeight,
                width: 22.toWidth,
                margin: EdgeInsets.only(right: 25),
                child: IconButton(
                  onPressed: navigateToDownloads,
                  icon: Icon(
                    Icons.save_alt_outlined,
                    size: 25.toFont,
                    color: ColorConstants.blueText,
                  ),
                ),
              )
            ],
    );
  }

  navigateToDownloads() async {
    // navigate to downloads folder
    if (Platform.isAndroid) {
      await FilesystemPicker.open(
        title: 'Atmosphere download folder',
        context: context,
        rootDirectory: BackendService.getInstance().downloadDirectory!,
        fsType: FilesystemType.all,
        folderIconColor: Colors.teal,
        allowedExtensions: [],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: () async =>
            await Permission.storage.request().isGranted,
      );
    } else {
      String url = 'shareddocuments://' +
          BackendService.getInstance().atClientPreference.downloadPath!;
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
