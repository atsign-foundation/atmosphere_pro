import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/apk.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
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
  bool isOpen = false;
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
    tabs = [Recents(), Videos(), Audios(), Documents()];
    tabNames = ['Recent', 'Videos', 'Audio', 'Document'];
    _controller =
        TabController(length: tabs.length, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.fadedBlue,
      body: SingleChildScrollView(
        child: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : Container(
                // reducing size by 75 , so that last list item will be shown
                height: SizeConfig().screenHeight - 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    DdesktopHeader(
                      title: "My Files",
                    ),
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
                        tabs: List<Text>.generate(
                            tabNames.length, (index) => Text(tabNames[index])),
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
    );
  }
}
