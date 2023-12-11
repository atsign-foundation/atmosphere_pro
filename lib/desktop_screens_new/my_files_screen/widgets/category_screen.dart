import 'dart:io';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/common_widgets/file_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/utils/file_category.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/widgets/file_list_tile_widget.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key, required this.fileType}) : super(key: key);

  final FileCategory fileType;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String searchText = '';
  bool isSearchActive = false;
  bool isGridType = true;
  FilesDetail? selectedFile;
  List<FilesDetail> files = [];

  setSelectedFileName(FilesDetail? file) {
    setState(() {
      selectedFile = file;
    });
  }

  String getTitle() {
    String title = "";
    switch (widget.fileType) {
      case FileCategory.Photos:
        title = "Photos";
        break;
      case FileCategory.Videos:
        title = "Videos";
        break;
      case FileCategory.Documents:
        title = "Documents";
        break;
      case FileCategory.Zips:
        title = "Zips";
        break;
      case FileCategory.Audios:
        title = "Audio";
        break;
      case FileCategory.Others:
        title = "Others";
        break;
      case FileCategory.AllFiles:
        title = "All Files";
        break;
      default:
        title = "";
        break;
    }
    return title;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    switch (widget.fileType) {
      case FileCategory.Photos:
        files = context.watch<MyFilesProvider>().receivedPhotos;
        break;
      case FileCategory.Videos:
        files = context.watch<MyFilesProvider>().receivedVideos;
        break;
      case FileCategory.Documents:
        files = context.watch<MyFilesProvider>().receivedDocument;
        break;
      case FileCategory.Zips:
        files = context.watch<MyFilesProvider>().receivedZip;
        break;
      case FileCategory.Audios:
        files = context.watch<MyFilesProvider>().receivedAudio;
        break;
      case FileCategory.Others:
        files = context.watch<MyFilesProvider>().receivedUnknown;
        break;
      case FileCategory.AllFiles:
        files = context.watch<MyFilesProvider>().allFiles;
        break;
      default:
        files = [];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      height: SizeConfig().screenHeight,
      color: ColorConstants.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    DesktopSetupRoutes.nested_push(
                        DesktopRoutes.DEKSTOP_MYFILES);
                  },
                  child:
                      Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  getTitle(),
                  style: TextStyle(
                    fontSize: 12.toFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                isSearchActive
                    ? Container(
                        margin: const EdgeInsets.only(left: 13.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            height: 40,
                            width: 308,
                            color: Colors.white,
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 8),
                                border: InputBorder.none,
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: ColorConstants.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: InkWell(
                                    onTap: () {
                                      searchText.isEmpty
                                          ? setState(() {
                                              isSearchActive = false;
                                            })
                                          : setState(() {
                                              searchText = '';
                                            });
                                    },
                                    child: const Icon(Icons.close)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        child: IconButtonWidget(
                          icon: AppVectors.icSearch,
                          onTap: () {
                            setState(() {
                              isSearchActive = true;
                            });
                          },
                        ),
                      ),
                SizedBox(
                  width: 10,
                ),
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
                            color:
                                isGridType ? Colors.white : Colors.transparent,
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
                            color:
                                isGridType ? Colors.transparent : Colors.white,
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
            SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 1,
              color: Colors.black,
            ),
            SizedBox(
              height: 10,
            ),

            // body
            files.isNotEmpty &
                    files.any(
                      (element) =>
                          (element.fileName ?? '').toLowerCase().contains(
                                searchText.toLowerCase(),
                              ),
                    )
                ? Wrap(
                    children: files.map((file) {
                      if ((file.fileName ?? "")
                              .toLowerCase()
                              .contains(searchText.toLowerCase()) ==
                          false) {
                        return SizedBox();
                      }
                      return InkWell(
                        onTap: () {
                          showFileDetailsDialog(file);
                          setSelectedFileName(file);
                        },
                        child: isGridType
                            ? FileTile(
                                key: UniqueKey(),
                                fileName: file.fileName ?? "",
                                fileSize: file.size ?? 0,
                                filePath: BackendService.getInstance()
                                        .downloadDirectory!
                                        .path +
                                    Platform.pathSeparator +
                                    (file.fileName ?? ""),
                                fileExt: file.fileName?.split(".").last ?? "",
                                fileDate: file.date ?? "",
                                selectedFile: selectedFile == file,
                                id: file.fileTransferId,
                              )
                            : FileListTile(
                                key: UniqueKey(),
                                fileName: file.fileName ?? "",
                                fileSize: file.size ?? 0,
                                filePath: BackendService.getInstance()
                                        .downloadDirectory!
                                        .path +
                                    Platform.pathSeparator +
                                    (file.fileName ?? ""),
                                fileExt: file.fileName?.split(".").last ?? "",
                                fileDate: file.date ?? "",
                                selectedFile: selectedFile == file,
                              ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text(
                      'No Data',
                      style: TextStyle(
                        color: ColorConstants.greyTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void showFileDetailsDialog(FilesDetail file) async {
    final date = DateTime.parse(file.date ?? "").toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    var isDeleting = false;

    //finding file sender to get file download location
    String? sender;
    String _filePath = '';
    var myFilesProvider = Provider.of<MyFilesProvider>(context, listen: false);
    var i = myFilesProvider.myFiles.indexWhere(
        (FileTransfer element) => element.key == file.fileTransferId);
    if (i != -1) {
      sender = myFilesProvider.myFiles[i].sender;
    }

    if (sender != null) {
      _filePath = MixedConstants.getFileDownloadLocationSync(sharedBy: sender) +
          Platform.pathSeparator +
          file.fileName!;
    } else {
      _filePath = file.filePath!;
    }

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              elevation: 5.0,
              clipBehavior: Clip.hardEdge,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.hardEdge,
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        // left: 31,
                        top: 16,
                        bottom: 16,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                    Container(
                      height: 400.toHeight,
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(horizontal: 33),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: thumbnail(
                          file.fileName?.split(".").last ?? "", _filePath),
                    ),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              await FileUtils.moveToSendFile(
                                  BackendService.getInstance()
                                          .downloadDirectory!
                                          .path +
                                      Platform.pathSeparator +
                                      (file.fileName ?? ""));
                              await DesktopSetupRoutes.nested_pop();
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              if (isDeleting == false) {
                                setDialogState(() {
                                  isDeleting = true;
                                });
                                var res = await context
                                    .read<MyFilesProvider>()
                                    .removeParticularFile(
                                        file.fileTransferId ?? "",
                                        file.fileName ?? "");

                                String filePath = BackendService.getInstance()
                                        .downloadDirectory!
                                        .path +
                                    Platform.pathSeparator +
                                    (file.contactName ?? '') +
                                    Platform.pathSeparator +
                                    (file.fileName ?? "");

                                File localFile = File(filePath);
                                bool fileExists = await localFile.exists();
                                if (fileExists && res) {
                                  localFile.deleteSync();
                                }

                                await SnackbarService().showSnackbar(
                                    context,
                                    res
                                        ? "Successfully deleted the file"
                                        : "failed to delete the file",
                                    bgColor: res
                                        ? ColorConstants.successGreen
                                        : ColorConstants.redAlert);

                                if (res) {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                  setSelectedFileName(null);
                                }
                              }

                              setDialogState(() {
                                isDeleting = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorConstants.lightGray,
                                  borderRadius: BorderRadius.circular(50)),
                              child: isDeleting
                                  ? const CircularProgressIndicator()
                                  : Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 16, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
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
                          ),
                          Text(
                            "${file.fileName}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            AppUtils.getFileSizeString(
                              bytes: file.size ?? 0,
                              decimals: 2,
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorConstants.oldSliver,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${file.contactName ?? ""}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: 13),
                          file.message != null
                              ? Text(
                                  "Message:",
                                  style: TextStyle(
                                    color: ColorConstants.textLightGray,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(height: 5),
                          Text(
                            "${file.message ?? ""}",
                            style: TextStyle(
                              color: ColorConstants.textLightGray,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
