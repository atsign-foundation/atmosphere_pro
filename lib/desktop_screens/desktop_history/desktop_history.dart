import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_received_file_details.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_received_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_sent_file_details.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_sent_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHistoryScreen extends StatefulWidget {
  final int tabIndex;
  Key key;
  DesktopHistoryScreen({this.tabIndex = 0, this.key});
  @override
  _DesktopHistoryScreenState createState() => _DesktopHistoryScreenState();
}

class _DesktopHistoryScreenState extends State<DesktopHistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  HistoryProvider historyProvider;
  int sentSelectedIndex = 0;
  String receivedSelectedFileId;
  FileHistory selectedSentFileData;
  FileTransfer receivedFileData;
  bool isSentTab = false;

  @override
  void didChangeDependencies() async {
    if (historyProvider == null) {
      _controller =
          TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
      _controller.addListener(onTabChanged);
      historyProvider = Provider.of<HistoryProvider>(context);
      if (historyProvider.sentHistory.isNotEmpty) {
        selectedSentFileData = historyProvider.sentHistory[0];
      }
      if (historyProvider.receivedHistoryLogs.isNotEmpty) {
        receivedFileData = historyProvider.receivedHistoryLogs[0];
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.removeListener(onTabChanged);
    super.dispose();
  }

  onTabChanged({int index}) {
    if (index == null) {
      index = _controller.index;
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
    if (historyProvider == null) {
      historyProvider = Provider.of<HistoryProvider>(context);
    }
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
                              style:
                                  TextStyle(letterSpacing: 0.1, fontSize: 20),
                            ),
                            Text(
                              TextStrings().received,
                              style:
                                  TextStyle(letterSpacing: 0.1, fontSize: 20),
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
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        ProviderHandler<HistoryProvider>(
                          functionName: historyProvider.SENT_HISTORY,
                          showError: false,
                          successBuilder: (provider) {
                            return (provider.sentHistory.isEmpty)
                                ? Center(
                                    child: Text('No files sent',
                                        style: TextStyle(fontSize: 15.toFont)),
                                  )
                                : ListView.separated(
                                    padding:
                                        EdgeInsets.only(bottom: 170.toHeight),
                                    physics: AlwaysScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        indent: 16.toWidth,
                                      );
                                    },
                                    itemCount: provider.sentHistory.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            sentSelectedIndex = index;
                                            selectedSentFileData =
                                                provider.sentHistory[index];
                                          });
                                        },
                                        child: DesktopSentFilesListTile(
                                          sentHistory:
                                              provider.sentHistory[index],
                                          key: Key(provider.sentHistory[index]
                                              .fileDetails.key),
                                          isSelected: index == sentSelectedIndex
                                              ? true
                                              : false,
                                        ),
                                      );
                                    },
                                  );
                          },
                          errorBuilder: (provider) => Center(
                            child: Text('Some error occured'),
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

                            return (provider.receivedHistoryLogs.isEmpty)
                                ? Center(
                                    child: Text(
                                      'No files received',
                                      style: TextStyle(fontSize: 15.toFont),
                                    ),
                                  )
                                : ListView.separated(
                                    padding:
                                        EdgeInsets.only(bottom: 170.toHeight),
                                    physics: AlwaysScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                      indent: 16.toWidth,
                                    ),
                                    itemCount:
                                        provider.receivedHistoryLogs.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          receivedFileData = provider
                                              .receivedHistoryLogs[index];

                                          setState(() {
                                            receivedSelectedFileId = provider
                                                .receivedHistoryLogs[index].key;
                                          });
                                        },
                                        child: DesktopReceivedFilesListTile(
                                          key: Key(provider
                                              .receivedHistoryLogs[index].key),
                                          receivedHistory: provider
                                              .receivedHistoryLogs[index],
                                          isSelected: receivedSelectedFileId ==
                                                  provider
                                                      .receivedHistoryLogs[
                                                          index]
                                                      .key
                                              ? true
                                              : false,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                          errorBuilder: (provider) => Center(
                            child: Text('Some error occured'),
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
                              key: Key(selectedSentFileData
                                  .fileTransferObject.transferId),
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
                              key: Key(receivedFileData.key),
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
    if (historyProvider.status[historyProvider.SENT_HISTORY] !=
        Status.Loading) {
      await historyProvider.getSentHistory();
    }

    if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
        Status.Loading) {
      await historyProvider.getReceivedHistory();
    }
  }
}
