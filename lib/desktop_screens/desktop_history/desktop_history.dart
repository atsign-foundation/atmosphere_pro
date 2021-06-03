import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_sent_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/desktop_transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/received_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHistoryScreen extends StatefulWidget {
  final int tabIndex;
  DesktopHistoryScreen({this.tabIndex = 0});
  @override
  _DesktopHistoryScreenState createState() => _DesktopHistoryScreenState();
}

class _DesktopHistoryScreenState extends State<DesktopHistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  HistoryProvider historyProvider;
  int selectedIndex = 0;
  FileHistory selectedFileData;

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
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      body: SingleChildScrollView(
          child: Row(
        children: <Widget>[
          Container(
            color: ColorConstants.fadedBlue,
            height: SizeConfig().screenHeight,
            width: SizeConfig().screenWidth * 0.5,
            child: Column(
              children: [
                Container(
                  height: 40.toHeight,
                  child: TabBar(
                    onTap: (index) async {
                      print('current tab: ${index}');
                    },
                    labelColor: ColorConstants.fontPrimary,
                    indicatorWeight: 5,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: CustomTextStyles.primaryBold14,
                    unselectedLabelStyle: CustomTextStyles.secondaryRegular14,
                    controller: _controller,
                    tabs: [
                      Text(
                        TextStrings().sent,
                        style: TextStyle(letterSpacing: 0.1, fontSize: 20),
                      ),
                      Text(
                        TextStrings().received,
                        style: TextStyle(letterSpacing: 0.1, fontSize: 20),
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
                                          selectedIndex = index;
                                          selectedFileData =
                                              provider.sentHistory[index];
                                        });
                                      },
                                      child: DesktopSentFilesListTile(
                                        sentHistory:
                                            provider.sentHistory[index],
                                        key: Key(provider.sentHistory[index]
                                            .fileDetails.key),
                                        isSelected: index == selectedIndex
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
                                separatorBuilder: (context, index) => Divider(
                                  indent: 16.toWidth,
                                ),
                                itemCount: provider.receivedHistoryLogs.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ReceivedFilesListTile(
                                    key: UniqueKey(),
                                    receivedHistory:
                                        provider.receivedHistoryLogs[index],
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
          Container(
            color: ColorConstants.selago,
            height: SizeConfig().screenHeight,
            width: SizeConfig().screenWidth * 0.5,
            padding: EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 15.toHeight),
                Row(
                  children: <Widget>[
                    getFIleImage(),
                    SizedBox(width: 25),
                    getFIleImage(),
                    Expanded(
                      child: SizedBox(),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                        return ColorConstants.dark_red;
                      }), textStyle:
                          MaterialStateProperty.resolveWith<TextStyle>(
                              (Set<MaterialState> states) {
                        return TextStyle(color: Colors.white);
                      })),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              'Resend',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15.toHeight),
                Row(
                  children: <Widget>[
                    Text(
                      '2 files . ',
                      style: CustomTextStyles.greyText15,
                    ),
                    Text('250 MB', style: CustomTextStyles.greyText15),
                  ],
                ),
                SizedBox(height: 15.toHeight),
                Text('Successfully transfered',
                    style: CustomTextStyles.greyText15),
                SizedBox(height: 15.toHeight),
                Text('August 12 2020', style: CustomTextStyles.greyText15),
                SizedBox(height: 15.toHeight),
                Text('To', style: CustomTextStyles.greyText15),
                SizedBox(height: 15.toHeight),
                selectedFileData != null
                    ? DesktopTranferOverlappingContacts(
                        selectedList: selectedFileData.sharedWith
                            .sublist(1, selectedFileData.sharedWith.length),
                        fileHistory: selectedFileData)
                    : SizedBox()
              ],
            ),
          )
        ],
      )),
    );
  }

  getFIleImage({String filepath, String fileName}) {
    return Row(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Image.asset(ImageConstants.pdfLogo),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File name',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 5),
              Text('250 MB', style: CustomTextStyles.greyText16),
            ],
          ),
        )
      ],
    );
  }
}
