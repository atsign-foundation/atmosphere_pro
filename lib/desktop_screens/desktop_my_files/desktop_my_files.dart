import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_input_field.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopMyFiles extends StatefulWidget {
  const DesktopMyFiles({Key? key}) : super(key: key);

  @override
  State<DesktopMyFiles> createState() => _DesktopMyFilesState();
}

class _DesktopMyFilesState extends State<DesktopMyFiles>
    with TickerProviderStateMixin {
  TabController? _controller;
  late MyFilesProvider myFilesProvider;
  bool _isFilterOption = false;
  List<Widget> tabs = [];
  List<String> tabNames = [];

  bool isLoading = false;

  @override
  void initState() {
    myFilesProvider = Provider.of<MyFilesProvider>(context, listen: false);
    ini();
    setState(() {});
    super.initState();
  }

  ini() async {
    tabs = [];
    tabNames = [];
    tabs = Provider.of<MyFilesProvider>(context, listen: false).tabs;
    tabNames = Provider.of<MyFilesProvider>(context, listen: false).tabNames;
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
                ? const Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorConstants.orange,
                    ),
                  ))
                : SizedBox(
                    // reducing size by 75 , so that last list item will be shown
                    height: SizeConfig().screenHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        DesktopHeader(
                            showBackIcon: false,
                            title: "My Files",
                            onFilter: (val) {
                              setState(() {
                                _isFilterOption = !_isFilterOption;
                              });
                            },
                            actions: [
                              DesktopCustomInputField(
                                  backgroundColor: Colors.white,
                                  hintText: 'Search...',
                                  icon: Icons.search,
                                  height: 45,
                                  iconColor: ColorConstants.greyText,
                                  value: (val) {
                                    myFilesProvider
                                        .setFileSearchText(val.toLowerCase());
                                  }),
                              const SizedBox(width: 15),
                              //TODO: filter option is removed from ui for now.
                              // InkWell(
                              //   onTap: () {
                              //     setState(() {
                              //       _isFilterOption = !_isFilterOption;
                              //     });
                              //   },
                              //   child: Container(
                              //     child: Icon(Icons.filter_list_sharp),
                              //   ),
                              // ),
                              // SizedBox(width: 10),
                            ]),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.only(left: 50),
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
                        const SizedBox(height: 15),
                        Expanded(
                          child: TabBarView(
                            controller: _controller,
                            physics: const ClampingScrollPhysics(),
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
                    padding: const EdgeInsets.only(
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
                            const Text(
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
                              child: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 10,
                          color: ColorConstants.greyText,
                        ),
                        getFilterOptionWidget('By type', true),
                        getFilterOptionWidget('By name', false),
                        getFilterOptionWidget('By size', false),
                        getFilterOptionWidget('By date', false),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return ColorConstants.orangeColor;
                            },
                          ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                            (Set<MaterialState> states) {
                              return const Size(120, 40);
                            },
                          )),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) {},
          activeColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}
