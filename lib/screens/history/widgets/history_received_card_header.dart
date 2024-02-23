import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/widgets/custom_ellipsis_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HistoryReceivedCardHeader extends StatefulWidget {
  final FileHistory fileHistory;

  const HistoryReceivedCardHeader({
    required this.fileHistory,
  });

  @override
  State<HistoryReceivedCardHeader> createState() => _HistoryReceivedCardHeaderState();
}

class _HistoryReceivedCardHeaderState extends State<HistoryReceivedCardHeader> {
  String nickname = '';
  int numberOfUnreadFile = 0;
  late TrustedContactProvider trustedContactProvider;
  bool isOpenRetryCard = false;

  @override
  void initState() {
    trustedContactProvider = TrustedContactProvider();
    getNickname();
    super.initState();
  }

  void getNickname() async {
    final String result = await CommonUtilityFunctions()
        .getNickname(widget.fileHistory.fileDetails?.sender ?? '');
    nickname = result;
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.fileHistory.type == HistoryType.received
        ? nickname.isNotEmpty
            ? nickname
            : widget.fileHistory.fileDetails?.sender ?? ''
        : widget.fileHistory.groupName ??
            '${widget.fileHistory.sharedWith?.length} Contact(s)';

    final String subTitle = widget.fileHistory.type == HistoryType.received
        ? widget.fileHistory.fileDetails?.sender ?? ''
        : (widget.fileHistory.sharedWith ?? [])
            .map((shareStatus) => shareStatus.atsign)
            .join(", ")
            .toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: CustomTextStyles.blackW60013,
                        ),
                        if (nickname.isNotEmpty ||
                            widget.fileHistory.type != HistoryType.received)
                          Text(
                            subTitle,
                            style: CustomTextStyles.blackW40012,
                          ),
                      ],
                    ),
                  ),
                  if (trustedContactProvider.trustedContacts.any((element) =>
                          element.atSign ==
                          widget.fileHistory.fileDetails?.sender) ||
                      (widget.fileHistory.sharedWith?.length == 1 &&
                          trustedContactProvider.trustedContacts.any(
                              (element) =>
                                  element.atSign ==
                                  widget.fileHistory.sharedWith?.single
                                      .atsign))) ...[
                    SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          AppVectors.icTrust,
                          color: ColorConstants.portlandOrange,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
            SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 4),
                Text(
                  DateFormat(MixedConstants.isToday(
                              widget.fileHistory.fileDetails?.date ??
                                  DateTime.now())
                          ? 'HH:mm'
                          : 'dd/MM/yyyy HH:mm')
                      .format(widget.fileHistory.fileDetails?.date ??
                          DateTime.now()),
                  style: CustomTextStyles.darkSliverW40012,
                ),
                // SizedBox(height: 4),
                // HistoryStatusBadges(
                //   key: UniqueKey(),
                //   fileHistory: widget.fileHistory,
                // ),
              ],
            )
          ],
        ),
        if ((widget.fileHistory.notes ?? '').isNotEmpty) ...[
        SizedBox(height: 4),
        CustomEllipsisTextWidget(
          text: '"${widget.fileHistory.notes}"',
          style: CustomTextStyles.darkSliverW40012,
          ellipsis: '... "',
          textAlign: TextAlign.left,
        )
        ],
      ],
    );
  }
}
