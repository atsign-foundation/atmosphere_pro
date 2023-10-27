import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_received_file_details.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_received_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_sent_file_details.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_sent_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHistoryScreen extends StatefulWidget {
  final int tabIndex;

  const DesktopHistoryScreen({
    Key? key,
    this.tabIndex = 0,
  }) : super(key: key);

  @override
  State<DesktopHistoryScreen> createState() => _DesktopHistoryScreenState();
}

class _DesktopHistoryScreenState extends State<DesktopHistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  late HistoryProvider historyProvider;
  int sentSelectedIndex = 0;
  String? receivedSelectedFileId;
  FileHistory? selectedSentFileData;
  FileTransfer? receivedFileData;
  bool isSentTab = false, _showSearchField = false;
  late TextEditingController _textController;

  @override
  void initState() {
    historyProvider =
        Provider.of<HistoryProvider>(NavService.navKey.currentContext!);
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _controller =
        TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
    _controller!.addListener(onTabChanged);

    if (historyProvider.sentHistory.isNotEmpty) {
      selectedSentFileData = historyProvider.sentHistory[0];
    }
    if (historyProvider.receivedHistoryLogs.isNotEmpty) {
      receivedFileData = historyProvider.receivedHistoryLogs[0];
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant DesktopHistoryScreen oldWidget) {
    var i = historyProvider.sentHistory.indexWhere((element) =>
        element.fileTransferObject?.transferId ==
        selectedSentFileData?.fileTransferObject?.transferId);
    if (i == -1 && historyProvider.sentHistory.isNotEmpty) {
      selectedSentFileData = historyProvider.sentHistory[0];
      sentSelectedIndex = 0;
    }

    var j = historyProvider.receivedHistoryLogs
        .indexWhere((element) => element.key == receivedFileData?.key);
    if (j == -1 && historyProvider.receivedHistoryLogs.isNotEmpty) {
      receivedFileData = historyProvider.receivedHistoryLogs[0];
      receivedSelectedFileId = historyProvider.receivedHistoryLogs[0].key;
    }

    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller!.removeListener(onTabChanged);
    _textController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      historyProvider.setHistorySearchText = '';
    });
    super.dispose();
  }

  onTabChanged({int? index}) {
    index ??= _controller!.index;
    if (index == 0) {
      isSentTab = true;
    } else if (index == 1) {
      isSentTab = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    historyProvider = Provider.of<HistoryProvider>(context);
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      body: SingleChildScrollView(
          child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: ColorConstants.fadedBlue,
              height: SizeConfig().screenHeight - 80,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TabBar(
                          labelColor: ColorConstants.fontPrimary,
                          indicatorWeight: 5,
                          indicatorColor: Colors.black,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: CustomTextStyles.primaryBold14,
                          unselectedLabelStyle:
                              CustomTextStyles.secondaryRegular14,
                          controller: _controller,
                          tabs: [
                            Text(
                              TextStrings().sent,
                              style: const TextStyle(
                                letterSpacing: 0.1,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              TextStrings().received,
                              style: const TextStyle(
                                letterSpacing: 0.1,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 25,
                        child: InkWell(
                            onTap: refreshHistoryScreen,
                            child: const Icon(Icons.refresh)),
                      ),
                      Positioned(
                        right: 45,
                        top: 25,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _showSearchField = true;
                              });
                            },
                            child: const Icon(Icons.search)),
                      ),
                    ],
                  ),
                  _showSearchField ? searchHistoryField() : const SizedBox(),
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        ProviderHandler<HistoryProvider>(
                          functionName: historyProvider.SENT_HISTORY,
                          showError: false,
                          successBuilder: (provider) {
                            if ((provider.sentHistory.isEmpty)) {
                              return Center(
                                child: Text(TextStrings().noFilesSent,
                                    style: TextStyle(
                                      fontSize: 15.toFont,
                                      fontWeight: FontWeight.normal,
                                    )),
                              );
                            } else {
                              List<FileHistory> filteredSentHistory = [];
                              for (var element in provider.sentHistory) {
                                if (element.sharedWith!.any(
                                      (ShareStatus sharedStatus) => sharedStatus
                                          .atsign!
                                          .contains(provider.getSearchText),
                                    ) ||
                                    (element.groupName != null &&
                                        element.groupName!
                                            .toLowerCase()
                                            .contains(provider.getSearchText
                                                .toLowerCase()))) {
                                  filteredSentHistory.add(element);
                                }
                              }
                              if (filteredSentHistory.isNotEmpty) {
                                return getSentHistory(filteredSentHistory);
                              } else {
                                return const Center(
                                  child: Text('No results found'),
                                );
                              }
                            }
                          },
                          errorBuilder: (provider) => Center(
                            child: Text(TextStrings().errorOccured),
                          ),
                          load: (provider) async {
                            provider.getSentHistory();
                          },
                        ),
                        ProviderHandler<HistoryProvider>(
                          functionName: historyProvider.RECEIVED_HISTORY,
                          load: (provider) async {
                            await provider.getReceivedHistory();
                          },
                          showError: false,
                          successBuilder: (provider) {
                            if (provider.receivedHistoryLogs.isNotEmpty &&
                                receivedSelectedFileId == null) {
                              receivedSelectedFileId =
                                  provider.receivedHistoryLogs[0].key;
                              receivedFileData =
                                  provider.receivedHistoryLogs[0];
                            }

                            if ((provider.receivedHistoryLogs.isEmpty)) {
                              return Center(
                                child: Text(
                                  TextStrings().noFilesRecieved,
                                  style: TextStyle(
                                    fontSize: 15.toFont,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            } else {
                              List<FileTransfer> filteredReceivedList = [];
                              for (var element
                                  in provider.receivedHistoryLogs) {
                                if (element.sender!.contains(
                                  provider.getSearchText,
                                )) {
                                  filteredReceivedList.add(element);
                                }
                              }

                              if (filteredReceivedList.isNotEmpty) {
                                return getReceivedTiles(filteredReceivedList);
                              } else {
                                return const Center(
                                    child: Text('No results found'));
                              }
                            }
                          },
                          errorBuilder: (provider) => Center(
                            child: Text(TextStrings().errorOccured),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: SizeConfig().screenHeight - 80,
              child: isSentTab
                  ? selectedSentFileData == null
                      ? const SizedBox()
                      : Consumer<HistoryProvider>(
                          builder: (context, provider, _) {
                            if (provider.sentHistory.isEmpty) {
                              return const SizedBox();
                            }

                            return DesktopSentFileDetails(
                              key: Key(selectedSentFileData!
                                  .fileTransferObject!.transferId),
                              selectedFileData: selectedSentFileData,
                            );
                          },
                        )
                  : receivedFileData == null
                      ? const SizedBox()
                      : Consumer<HistoryProvider>(
                          builder: (context, provider, _) {
                            if (provider.receivedHistoryLogs.isEmpty) {
                              return const SizedBox();
                            }

                            return DesktopReceivedFileDetails(
                              key: Key(receivedFileData!.key),
                              fileTransfer: receivedFileData,
                            );
                          },
                        ),
            ),
          )
        ],
      )),
    );
  }

  refreshHistoryScreen() async {
    if (historyProvider.status[historyProvider.PERIODIC_REFRESH] ==
        Status.Loading) {
      return;
    }
    if (historyProvider.status[historyProvider.SENT_HISTORY] !=
        Status.Loading) {
      await historyProvider.getSentHistory();
    }

    if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
        Status.Loading) {
      await historyProvider.getReceivedHistory();
    }
  }

  searchHistoryField() {
    return Container(
      height: 50.toHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConstants.receivedSelectedTileColor,
      ),
      padding: const EdgeInsets.fromLTRB(10, 3, 10, 5),
      margin: const EdgeInsets.fromLTRB(10, 3, 10, 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _textController,
              style: const TextStyle(fontSize: 12),
              onChanged: (String txt) {
                historyProvider.setHistorySearchText = txt;
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search history by atsign'),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _showSearchField = false;
                historyProvider.setHistorySearchText = "";
              });
            },
            child: const Icon(Icons.close),
          )
        ],
      ),
    );
  }

  Widget getReceivedTiles(List<FileTransfer> filteredReceivedList) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 170.toHeight),
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(
        indent: 16.toWidth,
      ),
      itemCount: filteredReceivedList.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            receivedFileData = filteredReceivedList[index];

            setState(() {
              receivedSelectedFileId = filteredReceivedList[index].key;
            });
          },
          child: DesktopReceivedFilesListTile(
            key: Key(filteredReceivedList[index].key),
            receivedHistory: filteredReceivedList[index],
            isSelected:
                receivedSelectedFileId == filteredReceivedList[index].key
                    ? true
                    : false,
          ),
        ),
      ),
    );
  }

  getSentHistory(List<FileHistory> filteredSentHistory) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 170.toHeight),
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Divider(
          indent: 16.toWidth,
        );
      },
      itemCount: filteredSentHistory.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              sentSelectedIndex = index;
              selectedSentFileData = filteredSentHistory[index];
            });
          },
          child: DesktopSentFilesListTile(
            sentHistory: filteredSentHistory[index],
            key: Key(filteredSentHistory[index].fileDetails!.key),
            isSelected: index == sentSelectedIndex ? true : false,
          ),
        );
      },
    );
  }
}
