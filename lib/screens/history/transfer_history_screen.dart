import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_history_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_card_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../data_models/file_entity.dart';
import '../../services/navigation_service.dart';
import '../../utils/text_strings.dart';
import '../../view_models/file_transfer_provider.dart';
import '../common_widgets/confirmation_dialog.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  bool isLoading = false;
  late HistoryProvider historyProvider;
  late TextEditingController searchController;
  GlobalKey filterKey = GlobalKey();

  @override
  void initState() {
    historyProvider = context.read<HistoryProvider>();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reloadView();
    });
    super.initState();
  }

  void reloadView() async {
    if (context.read<HistoryProvider>().hadNewFile) {
      await historyProvider.getAllFileTransferHistory();
      historyProvider.changeIsUpcomingEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBarCustom(
        height: 130,
        title: "History",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 18.toHeight,
            right: 22.toWidth,
            left: 34.toWidth,
            bottom: 16.toHeight,
          ),
          child: Row(
            children: [
              Expanded(
                child: SearchWidget(
                  controller: searchController,
                  borderColor: Colors.white,
                  backgroundColor: Colors.white,
                  hintText: "Search",
                  onChange: (text) {
                    setState(() {});
                    // provider.setHistorySearchText = text;
                  },
                  hintStyle: TextStyle(
                    color: ColorConstants.darkSliver,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  margin: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 16),
              InkWell(
                onTap: () {
                  _onTapFilterIcon();
                },
                child: SvgPicture.asset(
                  AppVectors.icFilter,
                  key: filterKey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (historyProvider.status[historyProvider.PERIODIC_REFRESH] !=
                  Status.Loading) {
                await historyProvider.getAllFileTransferHistory();
              }
            },
            child: ProviderHandler<HistoryProvider>(
              functionName: historyProvider.GET_ALL_FILE_HISTORY,
              showError: false,
              load: (provider) async {
                await historyProvider.getAllFileTransferHistory();
              },
              successBuilder: (provider) {
                if ((provider.displayFilesHistory.isEmpty)) {
                  return ListView.separated(
                    padding: EdgeInsets.only(bottom: 170.toHeight),
                    physics: AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        Divider(indent: 16.toWidth),
                    itemCount: 1,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: SizeConfig().screenHeight - 120.toHeight,
                        child: Center(
                          child: Text(
                            'No files sent',
                            style: TextStyle(
                              fontSize: 15.toFont,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  List<FileHistory> filteredFileHistory = [];

                  provider.displayFilesHistory.forEach((element) {
                    if (element.type == HistoryType.send) {
                      if (element.sharedWith!.any(
                            (ShareStatus sharedStatus) => sharedStatus.atsign!
                                .contains(searchController.text),
                          ) ||
                          (element.groupName != null &&
                              element.groupName!.toLowerCase().contains(
                                  searchController.text.toLowerCase()))) {
                        filteredFileHistory.add(element);
                      }
                    } else {
                      if (element.fileDetails!.sender!.contains(
                        searchController.text,
                      )) {
                        filteredFileHistory.add(element);
                      }
                    }
                  });

                  if (filteredFileHistory.isNotEmpty) {
                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 170.toHeight),
                      physics: AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10.toHeight);
                      },
                      itemCount: filteredFileHistory.length,
                      itemBuilder: (context, index) {
                        return HistoryCardWidget(
                          fileHistory: filteredFileHistory[index],
                        );

                        //   SentFilesListTile(
                        //   sentHistory: filteredSentHistory[index],
                        //   key: Key(filteredSentHistory[index].fileDetails!.key),
                        // );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('No results found'),
                    );
                  }
                }
              },
              errorBuilder: (provider) => ListView.separated(
                padding: EdgeInsets.only(bottom: 170.toHeight),
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    Divider(indent: 16.toWidth),
                itemCount: 1,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: SizeConfig().screenHeight - 120.toHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Some error occured',
                          style: TextStyle(
                            fontSize: 15.toFont,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 10.toHeight),
                        CustomButton(
                          isOrange: true,
                          buttonText: TextStrings().retry,
                          height: 40.toHeight,
                          width: 115.toWidth,
                          onPressed: () {
                            historyProvider.getAllFileTransferHistory();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapFilterIcon() async {
    RenderBox box = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    await showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            return FilterHistoryWidget(
              position: position,
              typeSelected: provider.typeSelected,
              isDesc: provider.isDesc,
              onSelected: (value) {
                provider.changeFilterType(value);
              },
              setOrder: (value) {
                provider.changeDesc(value);
                print(value);
              },
            );
          },
        );
      },
    );
  }

  void reUploadFileConfirmation(FileEntity fileEntity) async {
    await showDialog(
      context: NavService.navKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.toWidth),
          ),
          content: ConfirmationDialog(
            TextStrings.reUploadFileMsg,
            () async {
              FileData fileData = FileData(
                name: fileEntity.file!.name,
                size: fileEntity.file!.size,
                url: fileEntity.fileTransferObject.fileUrl,
              );

              var sentItemIndex =
                  Provider.of<HistoryProvider>(context, listen: false)
                      .sentHistory
                      .indexWhere((element) =>
                          element.fileTransferObject?.transferId ==
                          fileEntity.transferId);
              FileHistory? sentHistory;

              if (sentItemIndex != -1) {
                sentHistory =
                    Provider.of<HistoryProvider>(context, listen: false)
                        .sentHistory[sentItemIndex];
              } else {
                throw ('sent history not found');
              }

              await Provider.of<FileTransferProvider>(context, listen: false)
                  .reuploadFiles([fileData], 0, sentHistory);
            },
          ),
        );
      },
    );
  }

  void openFile(FileEntity fileEntity) async {
    String path = MixedConstants.RECEIVED_FILE_DIRECTORY +
        Platform.pathSeparator +
        (fileEntity.file!.name ?? '');

    if (fileEntity.historyType == HistoryType.send) {
      path = MixedConstants.SENT_FILE_DIRECTORY +
          Platform.pathSeparator +
          (fileEntity.file!.name ?? '');
    }

    File test = File(path);
    bool fileExists = await test.exists();
    if (fileExists) {
      await OpenFile.open(path);
    }
  }
}
