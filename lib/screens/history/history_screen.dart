import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/history_app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/received_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/sent_file_list_tile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  final int tabIndex;

  const HistoryScreen({Key? key, this.tabIndex = 0}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  bool isOpen = false;
  HistoryProvider? historyProvider;

  @override
  void didChangeDependencies() async {
    if (historyProvider == null) {
      _controller =
          TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
      historyProvider = Provider.of<HistoryProvider>(context);
    }

    super.didChangeDependencies();
  }

  @override
  dispose() {
    // closing all open received files widgets widgets.
    for (var element in historyProvider!.receivedHistoryLogs) {
      element.isWidgetOpen = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      appBar: HistoryAppBar(
        title: TextStrings().history,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: SizeConfig().screenHeight - 120.toHeight,
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: TabBar(
                  labelColor: ColorConstants.fontPrimary,
                  indicatorWeight: 5.toHeight,
                  indicatorColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: CustomTextStyles.primaryBold14,
                  unselectedLabelStyle: CustomTextStyles.secondaryRegular14,
                  controller: _controller,
                  tabs: [
                    Text(
                      TextStrings().sent,
                      style: const TextStyle(
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      TextStrings().received,
                      style: const TextStyle(
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    RefreshIndicator(
                      color: ColorConstants.orange,
                      onRefresh: () async {
                        if (historyProvider!
                                .status[historyProvider!.PERIODIC_REFRESH] !=
                            Status.Loading) {
                          await historyProvider!.getSentHistory();
                        }
                      },
                      child: ProviderHandler<HistoryProvider>(
                        functionName: historyProvider!.SENT_HISTORY,
                        showError: false,
                        successBuilder: (provider) {
                          if ((provider.sentHistory.isEmpty)) {
                            return ListView.separated(
                              padding: EdgeInsets.only(bottom: 170.toHeight),
                              physics: const AlwaysScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  Divider(indent: 16.toWidth),
                              itemCount: 1,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height:
                                      SizeConfig().screenHeight - 120.toHeight,
                                  child: Center(
                                    child: Text(
                                      'No files sent',
                                      style: TextStyle(
                                        fontSize: 15.toFont,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                      element.groupName!.toLowerCase().contains(
                                          provider.getSearchText
                                              .toLowerCase()))) {
                                filteredSentHistory.add(element);
                              }
                            }

                            if (filteredSentHistory.isNotEmpty) {
                              return getSentList(filteredSentHistory);
                            } else {
                              return const Center(
                                child: Text('No results found'),
                              );
                            }
                          }
                        },
                        errorBuilder: (provider) => ListView.separated(
                          padding: EdgeInsets.only(bottom: 170.toHeight),
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                      fontSize: 15.toFont,
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
                                      historyProvider!.getSentHistory();
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        load: (provider) async {},
                      ),
                    ),
                    RefreshIndicator(
                      color: ColorConstants.orange,
                      onRefresh: () async {
                        if (historyProvider!
                                .status[historyProvider!.PERIODIC_REFRESH] !=
                            Status.Loading) {
                          await historyProvider!.getReceivedHistory();
                        }
                      },
                      child: ProviderHandler<HistoryProvider>(
                          functionName: historyProvider!.RECEIVED_HISTORY,
                          load: (provider) async {},
                          showError: false,
                          successBuilder: (provider) {
                            if ((provider.receivedHistoryLogs.isEmpty)) {
                              return ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: const AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    Divider(indent: 16.toWidth),
                                itemCount: 1,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: SizeConfig().screenHeight -
                                        120.toHeight,
                                    child: Center(
                                      child: Text(
                                        'No files received',
                                        style: TextStyle(
                                          fontSize: 15.toFont,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
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
                                return getReceivedList(filteredReceivedList);
                              } else {
                                return const Center(
                                  child: Text('No results found'),
                                );
                              }
                            }
                          },
                          errorBuilder: (provider) => ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: const AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    Divider(indent: 16.toWidth),
                                itemCount: 1,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: SizeConfig().screenHeight -
                                        120.toHeight,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Some error occured',
                                          style: TextStyle(
                                            fontSize: 15.toFont,
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
                                            historyProvider!
                                                .getReceivedHistory();
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getSentList(List<FileHistory> filteredSentHistory) {
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
        return SentFilesListTile(
          sentHistory: filteredSentHistory[index],
          key: Key(filteredSentHistory[index].fileDetails!.key),
        );
      },
    );
  }

  Widget getReceivedList(List<FileTransfer> filteredReceivedList) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 170.toHeight),
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(indent: 16.toWidth),
      itemCount: filteredReceivedList.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReceivedFilesListTile(
          key: Key(filteredReceivedList[index].key),
          receivedHistory: filteredReceivedList[index],
          isWidgetOpen: filteredReceivedList[index].isWidgetOpen,
        ),
      ),
    );
  }
}
