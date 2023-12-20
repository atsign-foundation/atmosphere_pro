import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class HistoryFileList extends StatefulWidget {
  final HistoryType? type;
  final FileTransfer? fileTransfer;

  const HistoryFileList({
    required this.type,
    required this.fileTransfer,
  });

  @override
  State<HistoryFileList> createState() => _HistoryFileListState();
}

class _HistoryFileListState extends State<HistoryFileList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final int fileListLength = (widget.fileTransfer?.files ?? []).length;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorConstants.culturedColor,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 23,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemBuilder: (context, index) {
                    return buildIndicatorDot(
                      fileListLength >= 2 && !isExpanded && index >= 2
                          ? ColorConstants.inActiveIndicatorColor
                          : ColorConstants.orangeColor,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 4);
                  },
                  itemCount: fileListLength,
                ),
              ),
              Expanded(
                flex: 301,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
                  itemBuilder: (context, index) {
                    return HistoryFileItem(
                      key: UniqueKey(),
                      type: widget.type,
                      fileTransfer: widget.fileTransfer,
                      data: widget.fileTransfer!.files![index],
                    );
                  },
                  itemCount:
                      fileListLength > 2 && !isExpanded ? 2 : fileListLength,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 8);
                  },
                ),
              )
            ],
          ),
        ),
        if (fileListLength > 2) buildMoreFilesButton(fileListLength),
      ],
    );
  }

  Widget buildIndicatorDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget buildMoreFilesButton(int fileListLength) {
    return Positioned(
      bottom: 4,
      left: 0,
      right: 0,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(47),
              color: ColorConstants.moreFilesBackgroundColor,
            ),
            child: Text(
              isExpanded ? 'Show Less' : '${fileListLength - 2} More File(s)',
              style: TextStyle(
                color: ColorConstants.orangeColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
