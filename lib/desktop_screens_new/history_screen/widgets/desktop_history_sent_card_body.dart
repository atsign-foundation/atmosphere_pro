import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_list.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class DesktopHistorySentCardBody extends StatefulWidget {
  final FileHistory fileHistory;

  const DesktopHistorySentCardBody({
    required this.fileHistory,
  });

  @override
  State<DesktopHistorySentCardBody> createState() =>
      _DesktopHistorySentCardBodyState();
}

class _DesktopHistorySentCardBodyState
    extends State<DesktopHistorySentCardBody> {
  late HistoryProvider historyProvider =
      Provider.of<HistoryProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Selector<HistoryProvider, bool>(
      builder: (context, value, child) {
        return Column(
          children: [
            if (value) ...[
              DesktopHistoryFileList(
                fileTransfer: widget.fileHistory.fileDetails!,
                type: widget.fileHistory.type ?? HistoryType.send,
              ),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                if (!value)
                  Text(
                    '${widget.fileHistory.fileDetails?.files?.length} File${(widget.fileHistory.fileDetails?.files?.length ?? 0) > 1 ? 's' : ''} to ${widget.fileHistory.sharedWith?.length} Contact${(widget.fileHistory.sharedWith?.length ?? 0) > 1 ? 's' : ''}',
                    style: CustomTextStyles.darkSliverWW40012,
                  ),
                Spacer(),
                buildExpandDetailsButton(value),
              ],
            )
          ],
        );
      },
      selector: (_, p) =>
          p.listExpandedFiles.contains(widget.fileHistory.fileDetails?.key),
    );
  }

  Widget buildExpandDetailsButton(bool isExpand) {
    return InkWell(
      onTap: () {
        historyProvider
            .setExpandedFile(widget.fileHistory.fileDetails?.key ?? '');
      },
      child: Row(
        children: [
          Text(
            isExpand ? 'Collapse Details ' : 'Expand Details ',
            style: CustomTextStyles.raisinBlackW50012,
          ),
          SvgPicture.asset(
            isExpand
                ? AppVectors.icArrowUpOutline
                : AppVectors.icArrowDownOutline,
            height: 8,
            width: 12,
            fit: BoxFit.cover,
            color: ColorConstants.raisinBlack,
          )
        ],
      ),
    );
  }
}
