import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_entity.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_history_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_tab_bar.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_card_item.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class TransferHistoryScreen extends StatefulWidget {
  final bool isLoading;

  const TransferHistoryScreen({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen>
    with TickerProviderStateMixin {
  bool isFilterOpened = false;
  late HistoryProvider historyProvider;
  late TextEditingController searchController;
  bool isRefresh = true;
  GlobalKey filterKey = GlobalKey();
  bool isSearching = false;
  late TabController tabController;
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  void initState() {
    tabController =
        TabController(length: HistoryType.values.length - 1, vsync: this);
    historyProvider = context.read<HistoryProvider>();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reloadView();
    });
    super.initState();
  }

  void reloadView() async {
    if (context.read<HistoryProvider>().hadNewFile) {
      await historyProvider.getAllFileTransferHistory();
      historyProvider.changeIsUpcomingEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBarCustom(
        isLoading: widget.isLoading,
        height: 130,
        title: "History",
        suffixIcon: [
          buildIconButton(
            onTap: () {
              if (isSearching) {
                searchController.clear();
              }
              setState(() {
                isSearching = !isSearching;
              });
            },
            icon: isSearching
                ? AppVectors.icSelectedSearchFill
                : AppVectors.icSearchFill,
          ),
          SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 36),
            child: buildIconButton(
              onTap: () {
                _onTapFilterIcon();
                setState(() {
                  isFilterOpened = true;
                });
              },
              icon: isFilterOpened
                  ? AppVectors.icFilterOpened
                  : AppVectors.icFilter,
              key: filterKey,
            ),
          )
        ],
        skeletonLoading: _buildSkeletonLoadingAppBar(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        if (isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 4, 36, 8),
            child: SearchWidget(
              controller: searchController,
              borderColor: Colors.white,
              backgroundColor: Colors.white,
              hintText: "Search",
              onChange: (text) {
                setState(() {});
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
          child: RefreshIndicator(
            color: ColorConstants.orange,
            onRefresh: () async {
              if (historyProvider.status[historyProvider.PERIODIC_REFRESH] !=
                  Status.Loading) {
                setState(() {
                  isRefresh = false;
                });
                await historyProvider
                    .getAllFileTransferHistory()
                    .whenComplete(() => isRefresh = true);
              }
            },
            child: ProviderHandler<HistoryProvider>(
              functionName: historyProvider.GET_ALL_FILE_HISTORY,
              showError: false,
              showSkeletonLoading: widget.isLoading,
              load: (provider) async {
                await historyProvider.getAllFileTransferHistory();
              },
              successBuilder: (provider) {
                // if ((provider.displayFilesHistory.isEmpty)) {
                // return ListView.separated(
                //   padding: EdgeInsets.only(bottom: 170.toHeight),
                //   physics: AlwaysScrollableScrollPhysics(),
                //   separatorBuilder: (context, index) =>
                //       Divider(indent: 16.toWidth),
                //   itemCount: 1,
                //   itemBuilder: (context, index) => Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: SizedBox(
                //       height: SizeConfig().screenHeight - 120.toHeight,
                //       child: Center(
                //         child: Text(
                //           'No files',
                //           style: TextStyle(
                //             fontSize: 16.toFont,
                //             fontWeight: FontWeight.normal,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // );
                // } else {
                List<FileHistory> filteredFileHistory = [];

                provider.displayFilesHistory.forEach((element) {
                  if (element.type == HistoryType.send) {
                    if ((element.sharedWith ?? []).any(
                          (ShareStatus sharedStatus) => sharedStatus.atsign!
                              .contains(searchController.text),
                        ) ||
                        (element.groupName != null &&
                            element.groupName!.toLowerCase().contains(
                                searchController.text.toLowerCase()))) {
                      final FileHistory? filteredFile = getFilterFiles(element);
                      if (filteredFile != null) {
                        filteredFileHistory.add(filteredFile);
                      }
                    }
                  } else {
                    if ((element.fileDetails?.sender ?? '').contains(
                      searchController.text,
                    )) {
                      final FileHistory? filteredFile = getFilterFiles(element);
                      if (filteredFile != null) {
                        filteredFileHistory.add(filteredFile);
                      }
                    }
                  }
                });
                filteredFileHistory.sort(
                  (a, b) {
                    return b.fileDetails!.date!.compareTo(a.fileDetails!.date!);
                  },
                );

                return Column(
                  children: [
                    FilterTabBar(
                      tabController: tabController,
                      setType: (value) {
                        provider
                            .changeFilterType(HistoryType.values[value + 1]);
                      },
                      currentFilter: provider.typeSelected,
                    ),
                    SizedBox(height: 8),
                    (filteredFileHistory.isNotEmpty)
                        ? Expanded(
                            child: ListView.separated(
                              key: provider.typeSelected == HistoryType.received
                                  ? _one
                                  : _two,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 4),
                              physics: AlwaysScrollableScrollPhysics(),
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 12.toHeight);
                              },
                              itemCount:
                                  buildHistoryList(filteredFileHistory).length,
                              itemBuilder: (context, index) {
                                return buildHistoryList(
                                    filteredFileHistory)[index];
                              },
                            ),
                          )
                        : Center(
                            child: Text('No results found'),
                          ),
                  ],
                );
              },
              errorBuilder: (provider) => ListView.separated(
                padding: EdgeInsets.only(bottom: 170.toHeight),
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    Divider(indent: 16.toWidth),
                itemCount: 1,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: SizeConfig().screenHeight - 120.toHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Some error occured',
                          style: TextStyle(
                            fontSize: 16.toFont,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 10.toHeight),
                        CustomButton(
                          isOrange: true,
                          buttonText: TextStrings().retry,
                          height: 40.toHeight,
                          width: 115.toWidth,
                          onPressed: () {
                            historyProvider.getAllFileTransferHistory();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIconButton({
    required Function() onTap,
    required String icon,
    Key? key,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: 40,
        height: 40,
        key: key,
      ),
    );
  }

  Widget buildDateLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: ColorConstants.dateLabelColor,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
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

  List<Widget> buildHistoryList(List<FileHistory> data) {
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

    for (int i = 0; i < data.length; i++) {
      if (data[i].type == historyProvider.typeSelected) {
        final DateTime date = data[i].fileDetails!.date!;
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
          HistoryCardItem(
            key: UniqueKey(),
            fileHistory: data[i],
          ),
        );
      }
    }
    return result;
  }

  void _onTapFilterIcon() async {
    RenderBox box = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    await showDialog(
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            return FilterHistoryWidget(
              position: position,
              typeSelected: provider.typeSelected,
              onSelectedOptionalFilter: (value) {
                provider.updateListType(value);
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
      }
    });
  }

  void reUploadFileConfirmation(FileEntity fileEntity) async {
    await showDialog(
      context: NavService.navKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.toWidth),
          ),
          content: ConfirmationDialog(
            TextStrings.reUploadFileMsg,
            () async {
              FileData fileData = FileData(
                name: fileEntity.file!.name,
                size: fileEntity.file!.size,
                url: fileEntity.fileTransferObject.fileUrl,
              );

              var sentItemIndex =
                  Provider.of<HistoryProvider>(context, listen: false)
                      .sentHistory
                      .indexWhere((element) =>
                          element.fileTransferObject?.transferId ==
                          fileEntity.transferId);
              FileHistory? sentHistory;

              if (sentItemIndex != -1) {
                sentHistory =
                    Provider.of<HistoryProvider>(context, listen: false)
                        .sentHistory[sentItemIndex];
              } else {
                throw ('sent history not found');
              }

              await Provider.of<FileTransferProvider>(context, listen: false)
                  .reuploadFiles([fileData], 0, sentHistory);
            },
          ),
        );
      },
    );
  }

  void openFile(FileEntity fileEntity) async {
    String path = MixedConstants.RECEIVED_FILE_DIRECTORY +
        Platform.pathSeparator +
        (fileEntity.file!.name ?? '');

    if (fileEntity.historyType == HistoryType.send) {
      path = MixedConstants.SENT_FILE_DIRECTORY +
          Platform.pathSeparator +
          (fileEntity.file!.name ?? '');
    }

    File test = File(path);
    bool fileExists = await test.exists();
    if (fileExists) {
      await OpenFile.open(path);
    }
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
}
