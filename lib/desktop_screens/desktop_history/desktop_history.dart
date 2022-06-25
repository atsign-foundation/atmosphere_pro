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
  final Key? key;
  DesktopHistoryScreen({this.tabIndex = 0, this.key});
  @override
  _DesktopHistoryScreenState createState() => _DesktopHistoryScreenState();
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
  void dispose() {
    _controller!.removeListener(onTabChanged);
    _textController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      historyProvider.setHistorySearchText = '';
    });
    super.dispose();
  }

  onTabChanged({int? index}) {
    if (index == null) {
      index = _controller!.index;
    }
    if (index == 0) {
      isSentTab = true;
    } else if (index == 1) {
      isSentTab = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // historyProvider can't be null
    // if (historyProvider == null) {
    //   historyProvider = Provider.of<HistoryProvider>(context);
    // }
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
                        padding: EdgeInsets.symmetric(vertical: 20),
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
                              style: TextStyle(
                                letterSpacing: 0.1,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              TextStrings().received,
                              style: TextStyle(
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
                            child: Icon(Icons.refresh)),
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
                            child: Icon(Icons.search)),
                      ),
                    ],
                  ),
                  _showSearchField ? searchHistoryField() : SizedBox(),
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
                              provider.sentHistory.forEach((element) {
                                if (element.sharedWith!.any(
                                  (ShareStatus sharedStatus) => sharedStatus
                                      .atsign!
                                      .contains(provider.getSearchText),
                                )) {
                                  filteredSentHistory.add(element);
                                }
                              });
                              if (filteredSentHistory.isNotEmpty) {
                                return getSentHistory(filteredSentHistory);
                              } else {
                                return Center(
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
                              provider.receivedHistoryLogs.forEach((element) {
                                if (element.sender!.contains(
                                  provider.getSearchText,
                                )) {
                                  filteredReceivedList.add(element);
                                }
                              });

                              if (filteredReceivedList.isNotEmpty) {
                                return getReceivedTiles(filteredReceivedList);
                              } else {
                                return Center(child: Text('No results found'));
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
            child: Container(
              height: SizeConfig().screenHeight - 80,
              child: isSentTab
                  ? selectedSentFileData == null
                      ? SizedBox()
                      : Consumer<HistoryProvider>(
                          builder: (context, provider, _) {
                            if (provider.sentHistory.isEmpty) {
                              return SizedBox();
                            }

                            return DesktopSentFileDetails(
                              key: Key(selectedSentFileData!
                                  .fileTransferObject!.transferId),
                              selectedFileData: selectedSentFileData,
                            );
                          },
                        )
                  : receivedFileData == null
                      ? SizedBox()
                      : Consumer<HistoryProvider>(
                          builder: (context, provider, _) {
                            if (provider.receivedHistoryLogs.isEmpty) {
                              return SizedBox();
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
      padding: EdgeInsets.fromLTRB(10, 3, 10, 5),
      margin: EdgeInsets.fromLTRB(10, 3, 10, 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _textController,
              style: TextStyle(fontSize: 12),
              onChanged: (String txt) {
                historyProvider.setHistorySearchText = txt;
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search history by atsign'),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _showSearchField = false;
              });
            },
            child: Icon(Icons.close),
          )
        ],
      ),
    );
  }

  Widget getReceivedTiles(List<FileTransfer> filteredReceivedList) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 170.toHeight),
      physics: AlwaysScrollableScrollPhysics(),
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
      physics: AlwaysScrollableScrollPhysics(),
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
