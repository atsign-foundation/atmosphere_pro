import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_item_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_card_widget.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/sent_file_list_tile.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../data_models/file_entity.dart';
import '../../services/backend_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/text_strings.dart';
import '../../view_models/file_progress_provider.dart';
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
  late HistoryProvider provider;
  late TextEditingController searchController;

  @override
  void initState() {
    historyProvider = context.read<HistoryProvider>();
    provider = context.read<HistoryProvider>();
    searchController = TextEditingController();
    super.initState();
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
                  hintStyle: TextStyle(
                    color: ColorConstants.darkSliver,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  margin: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 16),
              SvgPicture.asset(
                AppVectors.icFilter,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (historyProvider.status[historyProvider.PERIODIC_REFRESH] !=
                  Status.Loading) {
                await historyProvider.getSentHistory();
              }
            },
            child: ProviderHandler<HistoryProvider>(
              functionName: historyProvider.SENT_HISTORY,
              showError: false,
              successBuilder: (provider) {
                if ((provider.sentHistory.isEmpty)) {
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
                  List<FileHistory> filteredSentHistory = [];
                  provider.sentHistory.forEach((element) {
                    if (element.sharedWith!.any(
                          (ShareStatus sharedStatus) => sharedStatus.atsign!
                              .contains(provider.getSearchText),
                        ) ||
                        (element.groupName != null &&
                            element.groupName!.toLowerCase().contains(
                                provider.getSearchText.toLowerCase()))) {
                      filteredSentHistory.add(element);
                    }
                  });

                  if (filteredSentHistory.isNotEmpty) {
                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 170.toHeight),
                      physics: AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10.toHeight);
                      },
                      itemCount: filteredSentHistory.length,
                      itemBuilder: (context, index) {
                        return HistoryCardWidget(
                          fileHistory: filteredSentHistory[index],
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
                            historyProvider.getSentHistory();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              load: (provider) async {},
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        OptionHeaderWidget(
          controller: searchController,
          margin: EdgeInsets.symmetric(horizontal: 22),
          onSearch: (content) {
            provider.setHistorySearchText = content;
            provider.searchFiles();
          },
          searchOffCallBack: () {
            searchController.clear();
            provider.setHistorySearchText = '';
            provider.searchFiles();
          },
          onReloadCallback: () async {
            provider.refreshData();
          },
          filterWidget: Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              return DropdownButtonHideUnderline(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: DropdownButton<HistoryType>(
                    value: provider.typeSelected,
                    icon: SvgPicture.asset(
                      AppVectors.icArrowDown,
                    ),
                    itemHeight: 56,
                    isExpanded: true,
                    isDense: true,
                    underline: null,
                    alignment: AlignmentDirectional.bottomEnd,
                    hint: Text(
                      "All",
                      style: TextStyle(
                        fontSize: 16.toFont,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.grey,
                      ),
                    ),
                    items: HistoryType.values.map(
                      (key) {
                        return key == HistoryType.all
                            ? DropdownMenuItem<HistoryType>(
                                value: key,
                                child: Center(
                                  child: Text(
                                    "All",
                                    style: TextStyle(
                                      fontSize: 14.toFont,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ColorConstants.sidebarTextUnselected,
                                    ),
                                  ),
                                ),
                              )
                            : DropdownMenuItem<HistoryType>(
                                value: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      color: ColorConstants.sidebarTileSelected,
                                      height: 1,
                                      width: double.infinity,
                                    ),
                                    key == HistoryType.received
                                        ? Container(
                                            width: double.infinity,
                                            child: FilterItemWidget(
                                              backgroundColor: ColorConstants
                                                  .yellow
                                                  .withOpacity(0.37),
                                              borderColor: ColorConstants.yellow
                                                  .withOpacity(0.37),
                                              prefixIcon: AppVectors.icReceive,
                                              title: "Received",
                                            ),
                                          )
                                        : FilterItemWidget(
                                            backgroundColor: ColorConstants
                                                .orangeColor
                                                .withOpacity(0.37),
                                            borderColor: ColorConstants
                                                .orangeColor
                                                .withOpacity(0.37),
                                            prefixIcon: AppVectors.icSend,
                                            title: "Sent",
                                          ),
                                  ],
                                ),
                              );
                      },
                    ).toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return HistoryType.values.map(
                        (key) {
                          return DropdownMenuItem<HistoryType>(
                            value: key,
                            child: Text(
                              key.text,
                              style: TextStyle(
                                fontSize: 16.toFont,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.grey,
                              ),
                            ),
                          );
                        },
                      ).toList();
                    },
                    onChanged: (type) {
                      provider.changeTypeSelected(type!);
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ProviderHandler<HistoryProvider>(
            errorBuilder: (provider) {
              return Center(
                child: Text('Something went wrong'),
              );
            },
            load: (provider) async {
              await provider.getAllFiles();
            },
            functionName: 'get_file_status',
            showError: false,
            successBuilder: (provider) {
              return Container(
                margin: EdgeInsets.only(
                  top: 16,
                  left: 25,
                  right: 21,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 24,
                      padding: EdgeInsets.only(left: 19),
                      decoration: BoxDecoration(
                        color: ColorConstants.textBoxBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          _buildTableTitle(title: "FileName", flex: 2),
                          _buildTableTitle(title: "Size", flex: 1),
                          _buildTableTitle(title: "Date", flex: 1),
                          _buildTableTitle(title: "Delivery", flex: 1),
                          _buildTableTitle(title: "atSign", flex: 2),
                          SizedBox(width: 36),
                        ],
                      ),
                    ),
                    _buildTableRow(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableTitle({
    required String title,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9.toFont,
                fontWeight: FontWeight.w600,
                color: ColorConstants.sidebarTextUnselected,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SvgPicture.asset(
            AppVectors.icSort,
          )
        ],
      ),
    );
  }

  Widget _buildTableRow() {
    return ProviderHandler<HistoryProvider>(
      functionName: provider.SENT_HISTORY,
      showError: false,
      successBuilder: (provider) {
        final files = provider.displayFiles;
        return Expanded(
          child: Scrollbar(
            child: RefreshIndicator(
              onRefresh: () async {
                provider.refreshData();
              },
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 110),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final DateFormat formatter = DateFormat('dd/MM/yy');
                  final String date = (files[index].date ?? '').isNotEmpty
                      ? formatter.format(DateTime.parse(
                          files[index].date!,
                        ))
                      : '';
                  bool isDownloadExpired =
                      AppUtils.isFilesAvailableToDownload(files[index].date!);

                  GlobalKey key = GlobalKey();

                  return SizedBox(
                    key: key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 19,
                            top: 7,
                            bottom: 6,
                          ),
                          child: InkWell(
                            onTap: () {
                              openFile(files[index]);
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    files[index].file?.name ?? '',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.textBlack,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    AppUtils.getFileSizeString(
                                      bytes: (files[index].file?.size ?? 0)
                                          .toDouble(),
                                      decimals: 2,
                                    ),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.textGray,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.textGrey,
                                    ),
                                  ),
                                ),
                                files[index].historyType == HistoryType.received
                                    ? Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FutureBuilder(
                                            future: isFilesAlreadyDownloaded(
                                                files[index]),
                                            builder: (_context,
                                                AsyncSnapshot<bool> snapsot) {
                                              if (snapsot.hasData) {
                                                return SvgPicture.asset(
                                                  files[index].historyType ==
                                                          HistoryType.received
                                                      ? AppVectors
                                                          .icReceiveBorder
                                                      : AppVectors.icSendBorder,
                                                  color: snapsot.data == true
                                                      ? Colors.green
                                                      : Color(0xFF939393),
                                                );
                                              } else {
                                                return SizedBox();
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: SvgPicture.asset(
                                            AppVectors.icSendBorder,
                                            color: files[index].isUploaded
                                                ? Colors.blue[200]
                                                : Color(0xFF939393),
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    files[index].atSign ?? '',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.textBlack,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                (files[index].note ?? '').isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          _onTapNoteIcon(
                                            key: key,
                                            note: files[index].note!,
                                          );
                                        },
                                        child: SvgPicture.asset(
                                          AppVectors.icNote,
                                        ),
                                      )
                                    : SizedBox(width: 16),
                                isDownloadExpired
                                    ? Consumer<FileProgressProvider>(
                                        builder: (_c, provider, _) {
                                        var fileTransferProgress =
                                            provider.receivedFileProgress[
                                                files[index].transferId];

                                        bool _showDownloadProgress = false;
                                        if (fileTransferProgress != null &&
                                            files[index]
                                                    .file
                                                    ?.name
                                                    ?.toLowerCase() ==
                                                fileTransferProgress.fileName
                                                    ?.toLowerCase()) {
                                          _showDownloadProgress = true;
                                        }

                                        if (_showDownloadProgress &&
                                            fileTransferProgress != null) {
                                          return fileTransferProgress.percent !=
                                                  null
                                              ? Container(
                                                  width: 30,
                                                  height: 30,
                                                  margin: EdgeInsets.all(6),
                                                  child:
                                                      LabelledCircularProgressIndicator(
                                                    value: (fileTransferProgress
                                                            .percent! /
                                                        100),
                                                  ),
                                                )
                                              : InfiniteSpinner();
                                        } else {
                                          return files[index].isUploading
                                              ? InfiniteSpinner()
                                              : InkWell(
                                                  onTap: () {
                                                    _onTapMoreIcon(
                                                        key, files[index]);
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                    child: Icon(
                                                      Icons.more_vert_outlined,
                                                      size: 16,
                                                      color:
                                                          ColorConstants.grey,
                                                    ),
                                                  ),
                                                );
                                        }
                                      })
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: ColorConstants.textBoxBg,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTapMoreIcon(GlobalKey key, FileEntity fileEntity) async {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    final size = box.size;

    await showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  right: 19,
                  top: position.dy - size.height - 28,
                  child: Container(
                    width: 188,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: ColorConstants.sidebarTextUnselected,
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: <Widget>[
                        fileEntity.historyType == HistoryType.send
                            ? Expanded(
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      reuploadFileConfirmation(fileEntity);
                                    },
                                    child: Text(
                                      "Resend",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: ColorConstants.textLightGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        /*Container(
                          color: ColorConstants.sidebarTextUnselected,
                          height: double.infinity,
                          width: 1,
                        ),*/
                        fileEntity.historyType == HistoryType.received
                            ? Expanded(
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }

                                      provider.downloadSingleFile(
                                        fileEntity.transferId,
                                        fileEntity.atSign,
                                        false,
                                        fileEntity.file!.name ?? '',
                                      );
                                    },
                                    child: Text(
                                      "Download",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: ColorConstants.textLightGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTapNoteIcon({
    required GlobalKey key,
    required String note,
  }) {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    final size = box.size;

    showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  right: 32,
                  top: position.dy - size.height - 4,
                  child: Container(
                    width: 247,
                    constraints: BoxConstraints(
                      minHeight: 79,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorConstants.sidebarTextUnselected,
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SvgPicture.asset(
                          AppVectors.icNote,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  reuploadFileConfirmation(FileEntity fileEntity) async {
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content:
                  ConfirmationDialog(TextStrings.reUploadFileMsg, () async {
                FileData fileData = FileData(
                    name: fileEntity.file!.name,
                    size: fileEntity.file!.size,
                    url: fileEntity.fileTransferObject.fileUrl);

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
              }));
        });
  }

  Future<bool> isFilesAlreadyDownloaded(FileEntity fileEntity) async {
    bool isFilesAvailableOfline = false;
    String path = BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        (fileEntity.file!.name ?? '');
    File test = File(path);
    bool fileExists = await test.exists();

    isFilesAvailableOfline = fileExists;
    return isFilesAvailableOfline;
  }

  openFile(FileEntity fileEntity) async {
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

  Widget InfiniteSpinner() {
    return Container(
      width: 30,
      height: 30,
      margin: EdgeInsets.all(6),
      child: CircularProgressIndicator(),
    );
  }
}
