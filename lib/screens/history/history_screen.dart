import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/history/widgets/file_list_tile.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool isOpen = false;
  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  List<Map<String, dynamic>> fakeData = [];
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
                    labelColor: ColorConstants.fontPrimary,
                    indicatorWeight: 5.toHeight,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: CustomTextStyles.primaryBold16,
                    unselectedLabelStyle: CustomTextStyles.secondaryRegular16,
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
                  child: TabBarView(controller: _controller, children: [
                    ListView.separated(
                      padding: EdgeInsets.only(bottom: 170.toHeight),
                      physics: AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(
                        indent: 16.toWidth,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilesListTile()),
                    ),
                    ListView.separated(
                      padding: EdgeInsets.only(bottom: 170.toHeight),
                      separatorBuilder: (context, index) => Divider(
                        indent: 16.toWidth,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilesListTile()),
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
