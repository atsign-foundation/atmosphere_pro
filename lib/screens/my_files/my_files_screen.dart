import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/enums/file_types.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
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

class _MyFilesScreenState extends State<MyFilesScreen> {
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
    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "My Files",
        description: "${context.watch<MyFilesProvider>().allFiles.length}",
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        OptionHeaderWidget(
          controller: searchController,
          onSearch: (content) {
            provider.setFileSearchText(content);
          },
          onReloadCallback: () async {
            await provider.getMyFilesRecords();
            await provider.getAllFiles();
          },
          searchOffCallBack: () {
            searchController.clear();
            provider.setFileSearchText('');
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
                                Text(
                                  key.text,
                                  style: TextStyle(
                                    fontSize: 12.toFont,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.grey,
                                  ),
                                ),
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
              await provider.getMyFilesRecords();
              await provider.getAllFiles();
            },
            functionName: 'all_files',
            showError: false,
            successBuilder: (provider) {
              final listFile = provider.displayFiles.where(
                (element) {
                  return (element.fileName?.toLowerCase() ?? '').contains(
                    provider.fileSearchText.toLowerCase(),
                  );
                },
              ).toList();

              return (listFile.isEmpty)
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
                        itemCount: listFile.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: 24.toHeight,
                          left: 28,
                          right: 28,
                          bottom: 100,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              await openFilePath(
                                listFile[index].filePath!,
                              );
                            },
                            onLongPress: () {
                              deleteFile(
                                listFile[index].filePath!,
                                fileTransferId: listFile[index].fileTransferId,
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
                                            "${listFile[index].fileName}",
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: ColorConstants.grayText,
                                              fontSize: 12.toFont,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          AppUtils.getFileSizeString(
                                            bytes: listFile[index].size ?? 0,
                                            decimals: 2,
                                          ),
                                          style: TextStyle(
                                            color: ColorConstants
                                                .sidebarTextUnselected,
                                            fontSize: 9.toFont,
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

  deleteFile(String filePath, {String? fileTransferId}) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(
        onConfirmation: () async {
          var file = File(filePath);
          if (await file.exists()) {
            file.deleteSync();
          }
          if (fileTransferId != null) {
            await Provider.of<MyFilesProvider>(
                    NavService.navKey.currentContext!,
                    listen: false)
                .removeParticularFile(fileTransferId,
                    filePath.split(Platform.pathSeparator).last);
          }
          await provider.getAllFiles();
        },
        deleteMessage: TextStrings.deleteFileConfirmationMsgMyFiles,
      ),
    );
  }
}
