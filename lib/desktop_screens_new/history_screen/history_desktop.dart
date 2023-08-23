import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_filter_history_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/history_list_tile.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HistoryDesktopScreen extends StatefulWidget {
  const HistoryDesktopScreen({Key? key}) : super(key: key);

  @override
  State<HistoryDesktopScreen> createState() => _HistoryDesktopScreenState();
}

class _HistoryDesktopScreenState extends State<HistoryDesktopScreen> {
  String searchText = '';
  bool isSearchActive = false;
  bool isSentSelected = true;

  GlobalKey filterKey = GlobalKey();
  bool isFilterOpened = false;

  List<FileHistory> historyfiles = [];
  List<FileHistory> filteredFiles = [];

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  void getHistory() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var provider = context.read<HistoryProvider>();
      await provider.getAllFileTransferHistory();
      historyfiles = provider.allFilesHistory;
      filteredFiles = provider.allFilesHistory;
      provider.setSelectedType(HistoryType.send);
    });
  }

  @override
  Widget build(BuildContext context) {
    HistoryType typeSelected = context.watch<HistoryProvider>().typeSelected;

    SizeConfig().init(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(40),
        color: ColorConstants.fadedBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Transfer History",
                  style: TextStyle(
                    fontSize: 12.toFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    context
                        .read<HistoryProvider>()
                        .setSelectedType(HistoryType.send);
                  },
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: typeSelected == HistoryType.send
                          ? Theme.of(context).primaryColor
                          : ColorConstants.MILD_GREY,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child: Text(
                      "Sent",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.toFont,
                      ),
                    )),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () async {
                    context
                        .read<HistoryProvider>()
                        .setSelectedType(HistoryType.received);
                  },
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: typeSelected == HistoryType.received
                          ? Theme.of(context).primaryColor
                          : ColorConstants.MILD_GREY,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child: Text(
                      "Received",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.toFont,
                      ),
                    )),
                  ),
                ),
                Spacer(),
                isSearchActive
                    ? Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            hintText: "Search...",
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSearchActive = !isSearchActive;
                      searchText = "";
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.search,
                      size: 25,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    _onTapFilterIcon();
                    setState(() {
                      isFilterOpened = true;
                    });
                  },
                  child: SvgPicture.asset(
                    isFilterOpened
                        ? AppVectors.icFilterOpened
                        : AppVectors.icFilterGray,
                  ),
                  key: filterKey,
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    var provider = context.read<HistoryProvider>();
                    await provider.getAllFileTransferHistory();
                    historyfiles = provider.allFilesHistory;
                    filteredFiles = provider.allFilesHistory;
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.refresh,
                      size: 25,
                    ),
                  ),
                ),
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

            //body

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Text(
                          typeSelected == HistoryType.received ? "From" : "To",
                          style: TextStyle(color: Color(0xFF909090)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            "Files",
                            style: TextStyle(color: Color(0xFF909090)),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 14,
                            color: Color(0xFF909090),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Text(
                          "Status",
                          style: TextStyle(color: Color(0xFF909090)),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          "Message",
                          style: TextStyle(color: Color(0xFF909090)),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(color: Color(0xFF909090)),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Type",
                          style: TextStyle(color: Color(0xFF909090)),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 14,
                          color: Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                var file = filteredFiles[index];
                return file.type == typeSelected &&
                        (file.fileDetails?.files?.isNotEmpty ?? false)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: HistoryCardWidget(
                          fileHistory: filteredFiles[index],
                          tags: getFileTags(filteredFiles[index]),
                        ),
                      )
                    : SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }

  // Used to filter files when we choose a filter from the header
  void filterFiles(List<FileType> selectedFileTypes) async {
    await context.read<HistoryProvider>().getAllFileTransferHistory();
    filteredFiles = context.read<HistoryProvider>().allFilesHistory;
    for (var filehistory in filteredFiles) {
      List<FileData> tempFiles = [];
      for (FileData file in filehistory.fileDetails?.files ?? []) {
        FileType type = getHistoryType(file);
        if (selectedFileTypes.contains(type)) {
          tempFiles.add(file);
        }
      }
      filehistory.fileDetails?.files = tempFiles;
    }

    setState(() {
      filteredFiles;
    });
  }

  // used to get the fileTypes (tags) in a group
  List<FileType> getFileTags(FileHistory files) {
    List<FileType> tags = [];
    for (FileData file in files.fileDetails?.files ?? []) {
      FileType type = getHistoryType(file);
      if (!tags.contains(type)) {
        tags.add(type);
      }
    }
    return tags;
  }

  FileType getHistoryType(FileData file) {
    var fileExt = file.name?.split(".").last ?? "";
    if (FileTypes.IMAGE_TYPES.contains(fileExt)) {
      return FileType.photo;
    } else if (FileTypes.DOCUMENT_TYPES.contains(fileExt)) {
      return FileType.file;
    } else if (FileTypes.AUDIO_TYPES.contains(fileExt)) {
      return FileType.audio;
    } else if (FileTypes.VIDEO_TYPES.contains(fileExt)) {
      return FileType.video;
    } else if (FileTypes.ZIP_TYPES.contains(fileExt)) {
      return FileType.zips;
    } else {
      return FileType.other;
    }
  }

  void _onTapFilterIcon() async {
    RenderBox box = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    await showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            provider.resetOptional();
            return SizedBox(
              width: 400,
              child: DesktopFilterHistoryWidget(
                position: position,
                typeSelected: provider.typeSelected,
                onSelectedOptionalFilter: (value) async {
                  await provider.updateFileType(value);
                  filterFiles(value);
                },
                listFileType: provider.listType,
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        isFilterOpened = false;
      });
    });
  }
}
