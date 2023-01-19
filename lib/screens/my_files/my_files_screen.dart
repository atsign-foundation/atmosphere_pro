import 'dart:math';

import 'package:atsign_atmosphere_pro/data_models/enums/file_types.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class MyFilesScreen extends StatefulWidget {
  @override
  _MyFilesScreenState createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen>
    with TickerProviderStateMixin {
  bool isOpen = false;
  List<Widget> tabs = [];
  List<String> tabNames = [];

  bool isLoading = false;
  Type runtimeType = Videos;
  late MyFilesProvider provider;
  late TextEditingController searchController;

  @override
  void initState() {
    provider = context.read<MyFilesProvider>();
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "My Files",
        description: '${provider.allFiles.length}',
      ),
      body: buildBody(),
    );
  }

  // Widget get buildLoading {
  //   return SafeArea(
  //     top: false,
  //     child: Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }

  Widget buildBody() {
    return Column(
      children: [
        OptionHeaderWidget(
          controller: searchController,
          onSearch: (content){

          },
          onReloadCallback: () async {
            await provider.getMyFilesRecords();
            await provider.getAllFiles();
          },
          filterWidget: Consumer<MyFilesProvider>(
            builder: (context, provider, _) {
              return DropdownButtonHideUnderline(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: DropdownButton<FileType>(
                    value: provider.typeSelected,
                    icon: SvgPicture.asset(
                      AppVectors.icArrowDown,
                    ),
                    isExpanded: true,
                    underline: null,
                    alignment: AlignmentDirectional.bottomEnd,
                    hint: Text(
                      "All",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.grey,
                      ),
                    ),
                    items: FileType.values.map(
                      (key) {
                        return DropdownMenuItem<FileType>(
                          value: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        key.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.grey,
                                        ),
                                      ),
                                    ),
                                    provider.typeSelected == key
                                        ? SvgPicture.asset(
                                            AppVectors.icCheck,
                                          )
                                        : SvgPicture.asset(
                                            AppVectors.icUnCheck,
                                          ),
                                  ],
                                ),
                              ),
                              Container(
                                color: ColorConstants.sidebarTileSelected,
                                height: 2,
                                width: double.infinity,
                              )
                            ],
                          ),
                        );
                      },
                    ).toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return FileType.values.map(
                        (key) {
                          return DropdownMenuItem<FileType>(
                            value: key,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    key.text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.grey,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: ColorConstants.sidebarTileSelected,
                                  height: 1,
                                  width: double.infinity,
                                )
                              ],
                            ),
                          );
                        },
                      ).toList();
                    },
                    onChanged: (type) {
                      provider.changeTypeSelected(type!);
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ProviderHandler<MyFilesProvider>(
            load: (provider) async {
              await provider.getAllFiles();
            },
            functionName: 'all_files',
            showError: false,
            successBuilder: (provider) {
              return (provider.displayFiles.isEmpty)
                  ? Center(
                      child: Text(
                        TextStrings().noFilesRecieved,
                        style: TextStyle(
                          fontSize: 15.toFont,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )
                  : Scrollbar(
                      child: ListView.builder(
                        itemCount: provider.displayFiles.length,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                            top: 24.toHeight, left: 28, right: 28),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              await openFilePath(
                                provider.displayFiles[index].filePath!,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorConstants.sidebarTextUnselected,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              margin: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            "${provider.displayFiles[index].fileName}",
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: ColorConstants.grayText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          getFileSizeString(
                                            bytes: provider
                                                    .displayFiles[index].size ??
                                                0,
                                            decimals: 2,
                                          ),
                                          style: TextStyle(
                                            color: ColorConstants
                                                .sidebarTextUnselected,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.remove_red_eye_outlined),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget fileCard(String? title, String? filePath, {String? fileTransferId}) {
    return InkWell(
      onLongPress: () {
        // deleteFile(filePath!, fileTransferId: fileTransferId);
      },
      child: Column(
        children: <Widget>[
          filePath != null
              ? Container(
                  width: 80.toHeight,
                  height: 80.toHeight,
                  color: Colors.purple,
                  // child: thumbnail(filePath.split('.').last, filePath),
                )
              : Container(
                  width: 80.toHeight,
                  height: 80.toHeight,
                  child: ClipRect(
                    child: Image.asset(
                      ImageConstants.emptyTrustedSenders,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
          title != null
              ? Container(
                  width: 100.toHeight,
                  height: 30.toHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF8A8E95),
                        fontSize: 12.toFont,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  static String getFileSizeString({required double bytes, int decimals = 0}) {
    const suffixes = ["b", "Kb", "Mb", "Gb", "Tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
