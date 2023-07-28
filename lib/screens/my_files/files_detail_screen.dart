import 'dart:io';
import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/sliver_grid_delegate.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilesDetailScreen extends StatefulWidget {
  final FileType? type;
  final bool? autoFocus;

  const FilesDetailScreen({
    Key? key,
    required this.type,
    this.autoFocus,
  }) : super(key: key);

  @override
  State<FilesDetailScreen> createState() => _FilesDetailScreenState();
}

class _FilesDetailScreenState extends State<FilesDetailScreen> {
  bool isGridType = true;
  late TextEditingController searchController;
  late MyFilesProvider provider;
  Uint8List? videoThumbnail;

  @override
  void initState() {
    searchController = TextEditingController();
    provider = context.read<MyFilesProvider>();
    super.initState();
    provider.changeTypeSelected(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        title: Text(
          widget.type != null ? "${widget.type!.text}" : "All Files",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 21,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: ColorConstants.dividerGrey,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      if (!isGridType) {
                        isGridType = !isGridType;
                      }
                    });
                  },
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: isGridType ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      isGridType
                          ? ImageConstants.icGridTypeActivate
                          : ImageConstants.icGridType,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isGridType) {
                        isGridType = !isGridType;
                      }
                    });
                  },
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: isGridType ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      isGridType
                          ? ImageConstants.icListType
                          : ImageConstants.icListTypeActivate,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: SearchWidget(
                controller: searchController,
                autoFocus: widget.autoFocus,
                borderColor: Colors.white,
                backgroundColor: Colors.white,
                hintText: "Search",
                onChange: (value) {
                  provider.searchFileByKeyword(
                    key: value,
                    type: widget.type,
                  );
                },
                hintStyle: TextStyle(
                  color: ColorConstants.darkSliver,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 75),
                child: Consumer<MyFilesProvider>(
                  builder: (context, provider, _) {
                    final files = provider.displayFiles;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        isGridType
                            ? _buildGridView(files)
                            : _buildListView(files),
                        Padding(
                          padding: EdgeInsets.only(top: 75),
                          child: Text(
                            "${files.length} items",
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorConstants.textGrey,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<FilesDetail> files) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 36),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: files.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          crossAxisCount: 4,
          crossAxisSpacing: 24,
          mainAxisSpacing: 22,
          height: 104,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: CommonUtilityFunctions().interactableThumbnail(
                  files[index].fileName?.split(".").last ?? "",
                  BackendService.getInstance().downloadDirectory!.path +
                      Platform.pathSeparator +
                      files[index].fileName!,
                  files[index],
                  () async {
                    await FileUtils.deleteFile(
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          files[index].fileName!,
                      fileTransferId: files[index].fileTransferId,
                      onComplete: () {
                        files.removeAt(index);
                      },
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    setState(() {});
                  },
                ),
              ),
              Spacer(),
              Flexible(
                child: Text(
                  files[index].fileName ?? "",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8.toFont,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(List<FilesDetail> files) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: NeverScrollableScrollPhysics(),
      itemCount: files.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final date = DateTime.parse(files[index].date ?? "").toLocal();
        final shortDate = DateFormat('MM/dd/yy').format(date);
        final time = DateFormat('kk:mm').format(date);

        // late FileTransfer fileTransfer;
        // bool isDownloaded = false;

        // for (var filetransfer in provider.myFiles) {
        //   if (filetransfer.key == files[index].fileTransferId) {
        //     fileTransfer = filetransfer;
        //     break;
        //   }
        // }

        return Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            extentRatio: 0.11,
            children: [
              // Consumer<FileProgressProvider>(
              //   builder: (_c, provider, _) {
              //     var fileTransferProgress =
              //         provider.receivedFileProgress[fileTransfer.key];

              //     return CommonUtilityFunctions()
              //             .checkForDownloadAvailability(fileTransfer)
              //         ? fileTransferProgress != null
              //             ? CommonUtilityFunctions().getDownloadStatus(
              //                 fileTransferProgress,
              //               )
              //             : isDownloaded
              //                 ? SvgPicture.asset(AppVectors.icCloudDownloaded)
              //                 : InkWell(
              //                     onTap: () async {
              //                       var res = await downloadFiles(
              //                         fileTransfer,
              //                         fileName: files[index].fileName,
              //                       );

              //                       setState(() {
              //                         isDownloaded = res;
              //                       });
              //                     },
              //                     child: SvgPicture.asset(
              //                       AppVectors.icDownloadFile,
              //                     ),
              //                   )
              //         : SizedBox();
              //   },
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 6.0),
              //   child: SvgPicture.asset(
              //     AppVectors.icDownloadFile,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () async {
                    await openFilePath(
                        BackendService.getInstance().downloadDirectory!.path +
                            Platform.pathSeparator +
                            files[index].fileName!);
                  },
                  child: SvgPicture.asset(
                    AppVectors.icSendFile,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () async {
                    await FileUtils.deleteFile(
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          files[index].fileName!,
                      fileTransferId: files[index].fileTransferId,
                      onComplete: () {
                        files.removeAt(index);
                      },
                    );
                    setState(() {});
                  },
                  child: SvgPicture.asset(
                    AppVectors.icDeleteFile,
                  ),
                ),
              ),
            ],
          ),
          child: InkWell(
            onTap: () async {
              await FileUtils.openFile(
                path: BackendService.getInstance().downloadDirectory!.path +
                    Platform.pathSeparator +
                    files[index].fileName!,
                extension: files[index].fileName?.split(".").last ?? "",
                onDelete: () async {
                  await FileUtils.deleteFile(
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          files[index].fileName!);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  setState(() {});
                },
                fileDetail: files[index],
              );
            },
            child: Container(
              key: UniqueKey(),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 49,
                    width: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: CommonUtilityFunctions().interactableThumbnail(
                          files[index].fileName?.split(".").last ?? "",
                          BackendService.getInstance().downloadDirectory!.path +
                              Platform.pathSeparator +
                              files[index].fileName!,
                          files[index], () async {
                        await FileUtils.deleteFile(
                          BackendService.getInstance().downloadDirectory!.path +
                              Platform.pathSeparator +
                              files[index].fileName!,
                          fileTransferId: files[index].fileTransferId,
                          onComplete: () {
                            files.removeAt(index);
                          },
                        );

                        if (mounted) {
                          Navigator.pop(context);
                        }
                        setState(() {});
                      }),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "${files[index].fileName}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "$shortDate",
                              style: TextStyle(
                                fontSize: 10,
                                color: ColorConstants.oldSliver,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 8,
                              color: Color(0xFFD7D7D7),
                              margin: EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                            ),
                            Text(
                              "$time",
                              style: TextStyle(
                                fontSize: 10,
                                color: ColorConstants.oldSliver,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Text(
                          "${(files[index].contactName)?.split("@")[1] ?? ''}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: 1),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "${files[index].contactName ?? ''}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Text(
                              AppUtils.getFileSizeString(
                                bytes: files[index].size ?? 0,
                                decimals: 2,
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: ColorConstants.oldSliver,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
