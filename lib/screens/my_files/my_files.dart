import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
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

class MyFiles extends StatefulWidget {
  @override
  _MyFilesState createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> with TickerProviderStateMixin {
  TabController _controller;
  HistoryProvider historyProvider;
  bool isOpen = false;

  List<String> tabsHeading = [
    TextStrings().recents,
    TextStrings().photos,
    TextStrings().videos,
    TextStrings().audio,
    TextStrings().apk,
    TextStrings().documents,
  ];
  List<Widget> tabsWidgets = [
    Recents(),
    Photos(),
    Videos(),
    Audios(),
    APK(),
    Documents(),
  ];
  bool isLoading = false;
  var runtimeType;
  @override
  void initState() {
    historyProvider = HistoryProvider();

    ini();
    setState(() {});
    super.initState();
  }

  ini() async {
    isLoading = true;
    await historyProvider.getRecievedHistory();
    _controller = TabController(
        length: historyProvider.tabs.length, vsync: this, initialIndex: 0);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        showTrailingIcon: true,
        showTitle: true,
        showLeadingIcon: true,
        titleText: TextStrings().myFiles,
        trailingIcon: (historyProvider.tabs.length > 1 &&
                (runtimeType == Videos ||
                    runtimeType == Documents ||
                    runtimeType == APK ||
                    runtimeType == Audios))
            ? PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (s) {
                  switch (s) {
                    case TextStrings.SORT_NAME:
                      providerCallback<HistoryProvider>(context,
                          task: (provider) {
                            if (runtimeType == Photos) {
                              provider.sortByName(provider.receivedPhotos);
                            } else if (runtimeType == Videos) {
                              provider.sortByName(provider.receivedVideos);
                            } else if (runtimeType == APK) {
                              provider.sortByName(provider.receivedApk);
                            } else if (runtimeType == Audios) {
                              provider.sortByName(provider.receivedAudio);
                            } else if (runtimeType == Documents) {
                              provider.sortByName(provider.receivedDocument);
                            }
                          },
                          taskName: (provider) => provider.SORT_LIST,
                          onSuccess: (provider) {});
                      break;
                    case TextStrings.SORT_SIZE:
                      providerCallback<HistoryProvider>(context,
                          task: (provider) {
                            if (runtimeType == Photos) {
                              provider.sortBySize(provider.receivedPhotos);
                            } else if (runtimeType == Videos) {
                              provider.sortBySize(provider.receivedVideos);
                            } else if (runtimeType == APK) {
                              provider.sortBySize(provider.receivedApk);
                            } else if (runtimeType == Audios) {
                              provider.sortBySize(provider.receivedAudio);
                            } else if (runtimeType == Documents) {
                              provider.sortBySize(provider.receivedDocument);
                            }
                          },
                          taskName: (provider) => provider.SORT_LIST,
                          onSuccess: (provider) {});
                      break;
                    case TextStrings.SORT_DATE:
                      providerCallback<HistoryProvider>(context,
                          task: (provider) {
                            if (runtimeType == Photos) {
                              provider.sortByDate(provider.receivedPhotos);
                            } else if (runtimeType == Videos) {
                              provider.sortByDate(provider.receivedVideos);
                            } else if (runtimeType == APK) {
                              provider.sortByDate(provider.receivedApk);
                            } else if (runtimeType == Audios) {
                              provider.sortByDate(provider.receivedAudio);
                            } else if (runtimeType == Documents) {
                              provider.sortByDate(provider.receivedDocument);
                            }
                          },
                          taskName: (provider) => provider.SORT_LIST,
                          onSuccess: (provider) {});
                      break;
                    default:
                  }
                },
                itemBuilder: (context) {
                  return {
                    TextStrings.SORT_NAME,
                    TextStrings.SORT_SIZE,
                    TextStrings.SORT_DATE
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                })
            : Container(),
        onTrailingIconPressed: () {
          setState(() {
            isOpen != isOpen;
          });
        },
      ),
      body: SingleChildScrollView(
        child: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: SizeConfig().screenHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      child: TabBar(
                        onTap: (index) {
                          Provider.of<HistoryProvider>(context, listen: false)
                              .getRecievedHistory();
                          Provider.of<HistoryProvider>(context, listen: false)
                              .sortFiles(historyProvider.receivedHistory);
                          setState(() {
                            runtimeType =
                                historyProvider.tabs[index].runtimeType;
                          });
                        },
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
                            historyProvider.tabNames.length,
                            (index) => Text(historyProvider.tabNames[index])),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        physics: ClampingScrollPhysics(),
                        children: historyProvider.tabs,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
