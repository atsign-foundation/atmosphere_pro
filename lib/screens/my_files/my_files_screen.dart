import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyFilesScreen extends StatefulWidget {
  @override
  _MyFilesScreenState createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen>
    with TickerProviderStateMixin {
  TabController? _controller;
  bool isOpen = false;
  List<Widget> tabs = [];
  List<String> tabNames = [];

  bool isLoading = false;
  Type runtimeType = Videos;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBarCustom(
          height: 130,
          title: "My Files",
          description: '3',
        ),
        body: isLoading ? buildLoading : buildBody());
  }

  Widget get buildLoading {
    return SafeArea(
      top: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        OptionHeaderWidget(),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
