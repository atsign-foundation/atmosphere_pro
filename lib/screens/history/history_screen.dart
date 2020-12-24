import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/history/widgets/file_list_tile.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool isOpen = false;
  HistoryProvider historyProvider;
  ContactProvider contactProvider;

  @override
  void didChangeDependencies() {
    if (historyProvider == null) {
      _controller = TabController(length: 2, vsync: this, initialIndex: 0);
      historyProvider = Provider.of<HistoryProvider>(context);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        print("fetched contacts");
        historyProvider.getSentHistory();
        historyProvider.getRecievedHistory();
      });
    }
    if (contactProvider == null) {
      contactProvider = Provider.of<ContactProvider>(context, listen: false);
    }

    super.didChangeDependencies();
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
                  onTap: (index) {
                    if (index == 0) {
                      Provider.of<HistoryProvider>(context, listen: false)
                          .getSentHistory();
                    }
                    if (index == 1) {
                      Provider.of<HistoryProvider>(context, listen: false)
                          .getRecievedHistory();
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
                      functionName: historyProvider.SENT_HISTORY,
                      showError: true,
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
                                    contactProvider: contactProvider),
                              ),
                            ),
                      // errorBuilder: (provider) => Center(
                      //   child: Text('Some error occured'),
                      // ),
                      load: (provider) {},
                    ),
                    ProviderHandler<HistoryProvider>(
                      functionName: historyProvider.RECEIVED_HISTORY,

                      load: (provider) async {
                        await provider.getRecievedHistory();
                      },
                      showError: true,
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
                                  sentHistory: provider.receivedHistory[index],
                                  contactProvider: contactProvider,
                                ),
                              ),
                            ),
                      // errorBuilder: (provider) => Center(
                      //   child: Text('Some error occured'),
                      // ),
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
