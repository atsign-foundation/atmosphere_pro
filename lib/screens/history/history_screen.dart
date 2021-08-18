import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/received_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/sent_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
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
  TabController _controller;
  bool isOpen = false;
  HistoryProvider historyProvider;

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
    historyProvider.receivedHistoryLogs.forEach((element) {
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
        title: 'History',
        showTrailingButton: true,
        trailingIcon: Icons.library_books,
        isHistory: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight,
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
                      style: TextStyle(letterSpacing: 0.1),
                    ),
                    Text(
                      TextStrings().received,
                      style: TextStyle(letterSpacing: 0.1),
                    )
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    ProviderHandler<HistoryProvider>(
                      functionName: historyProvider.SENT_HISTORY,
                      showError: true,
                      successBuilder: (provider) => (provider
                              .sentHistory.isEmpty)
                          ? Center(
                              child: Text('No files sent',
                                  style: TextStyle(fontSize: 15.toFont)),
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
                                      .sentHistory[index].fileDetails.key),
                                );
                              },
                            ),
                      errorBuilder: (provider) => Center(
                        child: Text('Some error occured'),
                      ),
                      load: (provider) async {
                        // provider.getSentHistory();
                      },
                    ),
                    ProviderHandler<HistoryProvider>(
                      functionName: historyProvider.RECEIVED_HISTORY,
                      load: (provider) async {
                        print('loading received');
                        // await provider.getReceivedHistory();
                      },
                      showError: true,
                      successBuilder: (provider) => (provider
                              .receivedHistoryLogs.isEmpty)
                          ? Center(
                              child: Text(
                                'No files received',
                                style: TextStyle(fontSize: 15.toFont),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.only(bottom: 170.toHeight),
                              physics: AlwaysScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  Divider(indent: 16.toWidth),
                              itemCount: provider.receivedHistoryLogs.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ReceivedFilesListTile(
                                  key: UniqueKey(),
                                  receivedHistory:
                                      provider.receivedHistoryLogs[index],
                                  isWidgetOpen: provider
                                      .receivedHistoryLogs[index].isWidgetOpen,
                                ),
                              ),
                            ),
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
    );
  }
}
