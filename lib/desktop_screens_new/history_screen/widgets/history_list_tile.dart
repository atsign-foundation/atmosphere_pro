import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/history_file_card.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HistoryCardWidget extends StatefulWidget {
  final FileHistory? fileHistory;
  final List<FileType> tags;
  final Function()? onDownloaded;

  const HistoryCardWidget({
    Key? key,
    this.fileHistory,
    this.onDownloaded,
    required this.tags,
  }) : super(key: key);

  @override
  State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
}

class _HistoryCardWidgetState extends State<HistoryCardWidget> {
  bool isExpanded = false;
  List<FileData>? filesList = [];

  @override
  void initState() {
    filesList = widget.fileHistory!.fileDetails!.files;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isExpanded ? Color(0xFFE9E9E9) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.fileHistory?.type == HistoryType.received
                            ? "${widget.fileHistory?.fileDetails?.sender ?? ''}"
                            : (widget.fileHistory?.sharedWith ?? [])
                                .map((shareStatus) => shareStatus.atsign)
                                .join(",")
                                .toString(),
                        style: TextStyle(
                          fontSize: 12.toFont,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "${filesList!.length}",
                          style: TextStyle(
                            fontSize: 13.toFont,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.textBlack,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorConstants.lightGreen,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: ColorConstants.textGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(33),
                              color: ColorConstants.lightGreen,
                            ),
                            child: Center(
                              child: Text(
                                widget.fileHistory?.type ==
                                        HistoryType.received
                                    ? "Received"
                                    : "Sent",
                                style: TextStyle(
                                  color: ColorConstants.textGreen,
                                  fontSize: 10.toFont,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.fileHistory?.type == HistoryType.send
                            ? widget.fileHistory?.notes ?? ''
                            : widget.fileHistory?.fileDetails?.notes ?? '',
                        style: TextStyle(
                          fontSize: 12.toFont,
                          color: Color(0xFF747474),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            '${DateFormat("MM/dd/yy").format(widget.fileHistory!.fileDetails!.date!)}',
                            style: TextStyle(
                              fontSize: 11.toFont,
                              color: ColorConstants.oldSliver,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${DateFormat('kk:mm').format(widget.fileHistory!.fileDetails!.date!)}',
                            style: TextStyle(
                              fontSize: 10.toFont,
                              color: ColorConstants.oldSliver,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ...widget.tags.map((tag) {
                            return Container(
                              decoration: BoxDecoration(
                                color: ColorConstants.MILD_GREY,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                tag.text,
                                style: TextStyle(
                                  color: Color(0xFF909090),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    isExpanded
                        ? SvgPicture.asset(AppVectors.icArrowUpOutline)
                        : SvgPicture.asset(AppVectors.icArrowDownOutline),
                  ],
                ),
              ],
            ),
          ),
        ),
        isExpanded
            ? ListView.builder(
                shrinkWrap: true,
                itemCount:
                    widget.fileHistory?.fileDetails?.files?.length ?? 0,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 4),
                itemBuilder: (context, index) {
                  return HistoryFileCard(
                    key: UniqueKey(),
                    fileTransfer: widget.fileHistory!.fileDetails!,
                    singleFile:
                        widget.fileHistory!.fileDetails!.files![index],
                    isShowDate: false,
                    margin: EdgeInsets.fromLTRB(36, 6, 20, 0),
                    onDownloaded: widget.onDownloaded,
                    historyType:
                        widget.fileHistory!.type ?? HistoryType.send,
                    fileHistory: widget.fileHistory!,
                  );
                },
              )
            : SizedBox(),
      ],
    );
  }
}
