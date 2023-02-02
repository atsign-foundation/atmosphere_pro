import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/option_header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_item_widget.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  bool isLoading = false;
  late HistoryProvider provider;
  late TextEditingController searchController;

  @override
  void initState() {
    provider = context.read<HistoryProvider>();
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        height: 130,
        title: "Transfer History",
      ),
      body: buildBody(),
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
                        fontSize: 16,
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
                                      fontSize: 14,
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
                                fontSize: 16,
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
                fontSize: 9,
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
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset(
                                    files[index].historyType ==
                                            HistoryType.received
                                        ? AppVectors.icReceiveBorder
                                        : AppVectors.icSendBorder,
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
                              InkWell(
                                onTap: () {
                                  _onTapMoreIcon(key);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.more_vert_outlined,
                                    size: 16,
                                    color: ColorConstants.grey,
                                  ),
                                ),
                              ),
                            ],
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

  void _onTapMoreIcon(GlobalKey key) {
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
                        Expanded(
                          child: Center(
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
                        Container(
                          color: ColorConstants.sidebarTextUnselected,
                          height: double.infinity,
                          width: 1,
                        ),
                        Expanded(
                          child: Center(
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
}