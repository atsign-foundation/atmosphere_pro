import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/files_detail_screen.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../services/backend_service.dart';

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
      backgroundColor: ColorConstants.background,
      appBar: AppBarCustom(
        height: 130,
        title: "Files",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(left: 34, bottom: 32),
      child: ProviderHandler<MyFilesProvider>(
        load: (provider) async {
          await provider.getAllFiles();
          await provider.getMyFilesRecords();
        },
        functionName: 'all_files',
        showError: false,
        successBuilder: (provider) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 18.toHeight,
                  right: 32.toWidth,
                ),
                child: SearchWidget(
                  controller: searchController,
                  readOnly: true,
                  borderColor: Colors.white,
                  backgroundColor: Colors.white,
                  hintText: "Search",
                  onTap: () {
                    navigateToFilesDetail(autoFocus: true);
                  },
                  hintStyle: TextStyle(
                    color: ColorConstants.darkSliver,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  margin: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Recent",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              provider.recentFile.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.recentFile.length,
                          padding: EdgeInsets.only(right: 32),
                          physics: ClampingScrollPhysics(),
                          separatorBuilder: (context, index) => SizedBox(
                            width: 16,
                          ),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 66,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: 85,
                                        width: 66,
                                        decoration: BoxDecoration(
                                          color: ColorConstants.lightSliver,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: thumbnail(
                                          provider.recentFile[index].fileName
                                                  ?.split(".")
                                                  .last ??
                                              "",
                                          BackendService.getInstance()
                                                  .downloadDirectory!
                                                  .path +
                                              Platform.pathSeparator +
                                              provider
                                                  .recentFile[index].fileName!,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: SvgPicture.asset(
                                          AppVectors.icBannerOverlay,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      "${provider.recentFile[index].filePath!.split(Platform.pathSeparator).last}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
              Text(
                "Category",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  children: _generateChildren(),
                ),
              ),
              SizedBox(height: 32),
              Container(
                height: 56,
                width: double.infinity,
                margin: EdgeInsets.only(left: 2, right: 36),
                padding: EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.raisinBlack,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    navigateToFilesDetail();
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "All Files",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${context.watch<MyFilesProvider>().allFiles.length}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.gray2,
                        ),
                      ),
                      Spacer(),
                      SvgPicture.asset(
                        AppVectors.icArrowRight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _generateItem(FileType fileType) {
    return InkWell(
      onTap: () {
        navigateToFilesDetail(type: fileType);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 110) / 3,
        height: 100,
        margin: EdgeInsets.only(right: 20, top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: fileType.backgroundColor,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                fileType.image,
              ),
              Text(
                fileType.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.toFont,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generateChildren() {
    List<Widget> items = [];

    for (int i = 0; i < FileType.values.length; i++) {
      items.add(
        _generateItem(FileType.values[i]),
      );
    }

    return items;
  }

  void navigateToFilesDetail({
    FileType? type,
    bool? autoFocus,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilesDetailScreen(
          type: type,
          autoFocus: autoFocus,
        ),
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
