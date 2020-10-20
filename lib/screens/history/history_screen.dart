import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/history/widgets/file_list_tile.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool isOpen = false;
  HistoryProvider provider;
  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    provider = HistoryProvider();
    provider.getSentHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstants.scaffoldColor,
        appBar: CustomAppBar(
          showTitle: true,
          title: 'History',
        ),
        body: SingleChildScrollView(
          child: Container(
            height: SizeConfig().screenHeight,
            child: Column(
              children: [
                Container(
                  height: 40,
                  child: TabBar(
                    onTap: (index) {
                      if (index == 0) {
                        provider.getSentHistory();
                      }
                      if (index == 1) {
                        provider.getRecievedHistory();
                      }
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
                      ),
                      Text(
                        TextStrings().received,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      ProviderHandler<HistoryProvider>(
                        functionName: provider.SENT_HISTORY,
                        successBuilder: (provider) => (provider
                                .sentHistory.isEmpty)
                            ? Center(
                                child: Text('No files sent'),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) => Divider(
                                  indent: 16.toWidth,
                                ),
                                itemCount: provider.sentHistory.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FilesListTile(
                                    sentHistory: provider.sentHistory[index],
                                  ),
                                ),
                              ),
                        errorBuilder: (provider) => Center(
                          child: Text('Some error occured'),
                        ),
                      ),
                      ProviderHandler<HistoryProvider>(
                        functionName: provider.RECEIVED_HISTORY,
                        successBuilder: (provider) => (provider
                                .receivedHistory.isEmpty)
                            ? Center(
                                child: Text('No files received'),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(bottom: 170.toHeight),
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) => Divider(
                                  indent: 16.toWidth,
                                ),
                                itemCount: provider.receivedHistory.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FilesListTile(
                                    sentHistory:
                                        provider.receivedHistory[index],
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
      ),
    );
  }
}
