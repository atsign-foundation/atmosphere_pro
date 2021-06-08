import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_recent.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_audios.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_documents.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopMyFiles extends StatefulWidget {
  @override
  _DesktopMyFilesState createState() => _DesktopMyFilesState();
}

class _DesktopMyFilesState extends State<DesktopMyFiles>
    with TickerProviderStateMixin {
  TabController _controller;
  HistoryProvider historyProvider;
  bool _isFilterOption = false;
  List<Widget> tabs = [];
  List<String> tabNames = [];

  bool isLoading = false;
  var runtimeType;
  @override
  void initState() {
    historyProvider = HistoryProvider();
    tabs = [Recents(), Videos(), Audios(), Documents()];
    ini();
    setState(() {});
    print('tabs: ${tabs}');
    super.initState();
  }

  ini() async {
    tabs = [];
    tabNames = [];
    tabs = Provider.of<HistoryProvider>(context, listen: false).tabs;
    tabNames = Provider.of<HistoryProvider>(context, listen: false).tabNames;
    tabs = [
      DesktopRecents(),
      DesktopVideos(),
      DesktopAudios(),
      DesktopDocuments()
    ];
    tabNames = ['Recent', 'Videos', 'Audio', 'Document'];
    _controller =
        TabController(length: tabs.length, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.fadedBlue,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: (isLoading)
                ? Center(child: CircularProgressIndicator())
                : Container(
                    // reducing size by 75 , so that last list item will be shown
                    height: SizeConfig().screenHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        DdesktopHeader(
                            title: "My Files",
                            onFilter: (val) {
                              setState(() {
                                _isFilterOption = !_isFilterOption;
                              });
                            }),
                        Container(
                          height: 40,
                          child: TabBar(
                            onTap: (index) async {},
                            isScrollable: true,
                            labelColor: ColorConstants.fontPrimary,
                            indicatorWeight: 5.toHeight,
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: CustomTextStyles.primaryBold14,
                            unselectedLabelStyle:
                                CustomTextStyles.secondaryRegular14,
                            controller: _controller,
                            tabs: List<Text>.generate(tabNames.length,
                                (index) => Text(tabNames[index])),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _controller,
                            physics: ClampingScrollPhysics(),
                            children: tabs,
                          ),
                        )
                      ],
                    ),
                  ),
          ),
          _isFilterOption
              ? Positioned(
                  right: 15,
                  top: 20,
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.only(
                        right: 10, left: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: ColorConstants.light_grey, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filters',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isFilterOption = !_isFilterOption;
                                });
                              },
                              child: Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                        Divider(
                          height: 10,
                          color: ColorConstants.greyText,
                        ),
                        getFilterOptionWidget('By type', true),
                        getFilterOptionWidget('By name', false),
                        getFilterOptionWidget('By size', false),
                        getFilterOptionWidget('By date', false),
                        SizedBox(
                          height: 15,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return ColorConstants.orangeColor;
                            },
                          ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                            (Set<MaterialState> states) {
                              return Size(100, 40);
                            },
                          )),
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget getFilterOptionWidget(String title, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) {},
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}
