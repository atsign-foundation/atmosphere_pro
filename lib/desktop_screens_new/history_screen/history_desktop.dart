import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_filter_history_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/destop_history_card_item.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HistoryDesktopScreen extends StatefulWidget {
  final HistoryType? historyType;

  const HistoryDesktopScreen({Key? key, this.historyType}) : super(key: key);

  @override
  State<HistoryDesktopScreen> createState() => _HistoryDesktopScreenState();
}

class _HistoryDesktopScreenState extends State<HistoryDesktopScreen> {
  bool isSearchActive = false;
  bool isSentSelected = true;

  late TextEditingController searchController = TextEditingController();

  GlobalKey filterKey = GlobalKey();
  bool isFilterOpened = false;
  late var screenWidth;
  late HistoryProvider historyProvider;

  List<FileHistory> filteredFiles = [];

  @override
  void initState() {
    super.initState();
    historyProvider = context.read<HistoryProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      historyProvider
          .setSelectedType(widget.historyType ?? HistoryType.received);
      filteredFiles = getDisplayFileData(historyProvider.allFilesHistory);
    });
  }

  Widget _buildSkeletonLoadingAppBar() {
    return Padding(
      padding: EdgeInsets.only(right: 32, bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SkeletonLoadingWidget(
              height: 48,
              borderRadius: BorderRadius.circular(47),
            ),
          ),
          SizedBox(width: 20),
          SkeletonLoadingWidget(
            height: 44,
            width: 44,
            borderRadius: BorderRadius.circular(48),
          ),
          SizedBox(width: 8),
          SkeletonLoadingWidget(
            height: 44,
            width: 44,
            borderRadius: BorderRadius.circular(48),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    HistoryType typeSelected = context.watch<HistoryProvider>().typeSelected;

    SizeConfig().init(context);
    screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 32),
        color: ColorConstants.background,
        child: ProviderHandler<HistoryProvider>(
            functionName: context.read<HistoryProvider>().GET_ALL_FILE_HISTORY,
            showSkeletonLoading: true,
            load: (provider) async {
              await provider.getAllFileTransferHistory();
              filteredFiles = getDisplayFileData(provider.allFilesHistory);
            },
            successBuilder: (provider) {
              filterSearchFiles();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Transfer History",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          context
                              .read<HistoryProvider>()
                              .setSelectedType(HistoryType.received);
                        },
                        child: Container(
                          width: 136,
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                      SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          context
                              .read<HistoryProvider>()
                              .setSelectedType(HistoryType.send);
                        },
                        child: Container(
                          width: 136,
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                      Spacer(),
                      isSearchActive
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                height: 40,
                                width: screenWidth <= 1380 ? 200 : 308,
                                color: Colors.white,
                                child: TextField(
                                  controller: searchController,
                                  autofocus: true,
                                  onChanged: (value) {
                                    setState(() {
                                      searchController.text = value;
                                    });
                                    filterSearchFiles();
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
                                        searchController.text.isEmpty
                                            ? setState(() {
                                                isSearchActive = false;
                                              })
                                            : setState(() {
                                                searchController.clear();
                                              });
                                      },
                                      child: const Icon(Icons.close),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : IconButtonWidget(
                              icon: AppVectors.icSearch,
                              onTap: () {
                                setState(() {
                                  isSearchActive = true;
                                });
                              },
                            ),
                      SizedBox(width: 12),
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
                          key: filterKey,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      IconButtonWidget(
                        onTap: () async {
                          var provider = context.read<HistoryProvider>();
                          historyProvider.resetData();
                          await provider.getAllFileTransferHistory();
                          filteredFiles =
                              getDisplayFileData(provider.allFilesHistory);
                        },
                        icon: AppVectors.icRefresh,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  //body
                  buildHistoryList.isNotEmpty
                      ? ListView.separated(
                          key: UniqueKey(),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: buildHistoryList.length,
                          itemBuilder: (context, index) {
                            return buildHistoryList[index];
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 12);
                          },
                        )
                      : Center(
                          child: Text('No results found'),
                        )
                ],
              );
            }),
      ),
    );
  }

  List<FileHistory> getDisplayFileData(List<FileHistory> data) {
    List<FileHistory> result = [];

    for (FileHistory i in data) {
      final FileHistory? filteredFile = getFilterFiles(i);
      if (filteredFile != null) {
        result.add(filteredFile);
      }
    }

    return result;
  }

  void filterSearchFiles() {
    var files = getDisplayFileData(historyProvider.allFilesHistory);
    if (searchController.text.trim().isEmpty) {
      filteredFiles = files;
      return;
    }
    List<FileHistory> tempFiles = [];
    for (var filehistory in files) {
      for (FileData file in filehistory.fileDetails?.files ?? []) {
        final isFileContained = file.name
                ?.toLowerCase()
                .contains(searchController.text.toLowerCase()) ??
            false;
        final isAtSignContained =
            (historyProvider.typeSelected == HistoryType.received
                    ? filehistory.fileDetails?.sender
                        ?.toLowerCase()
                        .contains(searchController.text.toLowerCase())
                    : filehistory.sharedWith?.any((element) =>
                        (element.atsign ?? '')
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))) ??
                false;
        if (isFileContained || isAtSignContained) {
          tempFiles.add(filehistory);
          continue;
        }
      }
    }
    filteredFiles = tempFiles;
  }

  void _onTapFilterIcon() async {
    RenderBox box = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    await showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            return DesktopFilterHistoryWidget(
              position: position,
              typeSelected: provider.typeSelected,
              onSelectedOptionalFilter: (value) async {
                provider.updateListType(value);
                filteredFiles = getDisplayFileData(provider.allFilesHistory);
              },
              listFileType: provider.listType,
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        isFilterOpened = false;
      });
      if (historyProvider.listType.isEmpty) {
        historyProvider.resetOptional();
        filteredFiles = getDisplayFileData(historyProvider.allFilesHistory);
      }
    });
  }

  FileHistory? getFilterFiles(FileHistory data) {
    List<FileData> listFile = [];

    data.fileDetails?.files?.forEach((element) {
      String? fileExtension = element.name?.split('.').last;
      for (int i = 0; i < historyProvider.listType.length; i++) {
        if (FileTypes.ALL_TYPES.contains(fileExtension)) {
          if (historyProvider.listType[i].suffixName.contains(fileExtension)) {
            listFile.add(element);
          }
          continue;
        }
        if (historyProvider.listType[i] == FileType.other) {
          listFile.add(element);
          continue;
        }
      }
    });

    if (listFile.isNotEmpty) {
      final FileTransfer fileDetails = FileTransfer(
        url: data.fileDetails!.url,
        key: data.fileDetails!.key,
        fileEncryptionKey: data.fileDetails!.fileEncryptionKey,
        date: data.fileDetails!.date,
        expiry: data.fileDetails!.expiry,
        files: listFile,
        isUpdate: data.fileDetails!.isUpdate,
        isWidgetOpen: data.fileDetails!.isWidgetOpen,
        notes: data.fileDetails!.notes,
        platformFiles: data.fileDetails!.platformFiles,
        sender: data.fileDetails!.sender,
      );
      return FileHistory(
        fileDetails,
        data.sharedWith,
        data.type,
        data.fileTransferObject,
        notes: data.notes,
        groupName: data.groupName,
        isOperating: data.isOperating,
      );
    }
    return null;
  }

  Widget buildDateLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: ColorConstants.sidebarTextUnselected,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  List<Widget> get buildHistoryList {
    List<Widget> result = [];

    final DateTime current = DateTime.now();

    final Widget todayLabel = buildDateLabel(MixedConstants.DATE_LABELS[0]);
    final Widget yesterdayLabel = buildDateLabel(MixedConstants.DATE_LABELS[1]);
    final Widget thisWeekLabel = buildDateLabel(MixedConstants.DATE_LABELS[2]);
    final Widget lastWeekLabel = buildDateLabel(MixedConstants.DATE_LABELS[3]);
    final Widget thisMonthLabel = buildDateLabel(MixedConstants.DATE_LABELS[4]);
    final Widget lastMonthLabel = buildDateLabel(MixedConstants.DATE_LABELS[5]);
    final Widget thisYearLabel = buildDateLabel(MixedConstants.DATE_LABELS[6]);
    final Widget lastYearLabel = buildDateLabel(MixedConstants.DATE_LABELS[7]);

    for (int i = 0; i < filteredFiles.length; i++) {
      if (filteredFiles[i].type ==
          context.watch<HistoryProvider>().typeSelected) {
        final DateTime date = filteredFiles[i].fileDetails!.date!;
        if (MixedConstants.isToday(date)) {
          if (!result.contains(todayLabel)) {
            result.add(todayLabel);
          }
        } else if (MixedConstants.isYesterday(date)) {
          if (!result.contains(yesterdayLabel)) {
            result.add(yesterdayLabel);
          }
        } else if (MixedConstants.isThisWeek(date)) {
          if (!result.contains(thisWeekLabel)) {
            result.add(thisWeekLabel);
          }
        } else if (MixedConstants.isLastWeek(date)) {
          if (!result.contains(lastWeekLabel)) {
            result.add(lastWeekLabel);
          }
        } else if ((date.year == current.year) &&
            (date.month == current.month)) {
          if (!result.contains(thisMonthLabel)) {
            result.add(thisMonthLabel);
          }
        } else if (MixedConstants.isLastMonth(date)) {
          if (!result.contains(lastMonthLabel)) {
            result.add(lastMonthLabel);
          }
        } else if (date.year == current.year) {
          if (!result.contains(thisYearLabel)) {
            result.add(thisYearLabel);
          }
        } else /* if (MixedConstants.isLastYear(date))*/ {
          if (!result.contains(lastYearLabel)) {
            result.add(lastYearLabel);
          }
        }
        result.add(
          DesktopHistoryCardItem(
            key: UniqueKey(),
            fileHistory: filteredFiles[i],
          ),
        );
      }
    }
    return result;
  }
}
