import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
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
  HistoryScreen({this.tabIndex = 0});
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
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
    historyProvider!.receivedHistoryLogs.forEach((element) {
      element.isWidgetOpen = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      appBar: CustomAppBar(
        showBackButton: true,
        showTitle: true,
        title: TextStrings().history,
        showTrailingButton: true,
        trailingIcon: Icons.save_alt_outlined,
        isHistory: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight - 120.toHeight,
          child: Column(
            children: [
              Container(
                height: 40,
                child: TabBar(
                  onTap: (index) async {
                    print('current tab: ${index}');
                  },
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
                      style: TextStyle(
                          letterSpacing: 0.1, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      TextStrings().received,
                      style: TextStyle(
                          letterSpacing: 0.1, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    RefreshIndicator(
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
                        successBuilder: (provider) => (provider
                                .sentHistory.isEmpty)
                            ? ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: AlwaysScrollableScrollPhysics(),
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
                                        'No files sent',
                                        style: TextStyle(
                                            fontSize: 15.toFont,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    indent: 16.toWidth,
                                  );
                                },
                                itemCount: provider.sentHistory.length,
                                itemBuilder: (context, index) {
                                  return SentFilesListTile(
                                    sentHistory: provider.sentHistory[index],
                                    key: Key(provider
                                        .sentHistory[index].fileDetails!.key!),
                                  );
                                },
                              ),
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
                              child: Center(
                                child: Text(
                                  'Some error occured',
                                  style: TextStyle(
                                      fontSize: 15.toFont,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ),
                        load: (provider) async {},
                      ),
                    ),
                    RefreshIndicator(
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
                          successBuilder: (provider) => (provider
                                  .receivedHistoryLogs.isEmpty)
                              ?
                              // Used a listview for RefreshIndicator to be active.
                              ListView.separated(
                                  padding:
                                      EdgeInsets.only(bottom: 170.toHeight),
                                  physics: AlwaysScrollableScrollPhysics(),
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
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      EdgeInsets.only(bottom: 170.toHeight),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      Divider(indent: 16.toWidth),
                                  itemCount:
                                      provider.receivedHistoryLogs.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ReceivedFilesListTile(
                                      key: Key(provider
                                          .receivedHistoryLogs[index].key!),
                                      receivedHistory:
                                          provider.receivedHistoryLogs[index],
                                      isWidgetOpen: provider
                                          .receivedHistoryLogs[index]
                                          .isWidgetOpen,
                                    ),
                                  ),
                                ),
                          errorBuilder: (provider) => ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: AlwaysScrollableScrollPhysics(),
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
                                        'Some error occured',
                                        style: TextStyle(
                                            fontSize: 15.toFont,
                                            fontWeight: FontWeight.normal),
                                      ),
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
}
