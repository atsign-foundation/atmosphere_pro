import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_status_badges.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HistoryCardHeader extends StatefulWidget {
  final FileHistory fileHistory;

  const HistoryCardHeader({
    required this.fileHistory,
  });

  @override
  State<HistoryCardHeader> createState() => _HistoryCardHeaderState();
}

class _HistoryCardHeaderState extends State<HistoryCardHeader> {
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
            '${widget.fileHistory.sharedWith?.length} Contacts';

    final String subTitle = widget.fileHistory.type == HistoryType.received
        ? widget.fileHistory.fileDetails?.sender ?? ''
        : (widget.fileHistory.sharedWith ?? [])
            .map((shareStatus) => shareStatus.atsign)
            .join(", ")
            .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                            style: CustomTextStyles.blackW40011,
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
                    SvgPicture.asset(
                      AppVectors.icTrust,
                      color: ColorConstants.portlandOrange,
                      width: 20,
                      height: 20,
                    )
                  ]
                ],
              ),
            ),
            SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat(MixedConstants.isToday(
                              widget.fileHistory.fileDetails?.date ??
                                  DateTime.now())
                          ? 'HH:mm'
                          : 'dd/MM/yyyy HH:mm')
                      .format(widget.fileHistory.fileDetails?.date ??
                          DateTime.now()),
                  style: CustomTextStyles.raisinBlackW40011,
                ),
                SizedBox(height: 4),
                HistoryStatusBadges(
                  key: UniqueKey(),
                  fileHistory: widget.fileHistory,
                ),
              ],
            )
          ],
        ),
        if ((widget.fileHistory.fileDetails?.notes ?? '').isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            '"${widget.fileHistory.fileDetails?.notes}"',
            style: CustomTextStyles.raisinBlackW40010,
          )
        ],
      ],
    );
  }
}
