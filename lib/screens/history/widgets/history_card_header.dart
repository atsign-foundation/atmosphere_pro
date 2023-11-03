import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_retry_card.dart';
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
  final HistoryType? type;
  final String? sender;
  final String? groupName;
  final List<ShareStatus> sharedWith;
  final String note;
  final DateTime date;
  final List<String> fileNameList;

  const HistoryCardHeader({
    required this.type,
    required this.sender,
    required this.groupName,
    required this.sharedWith,
    required this.note,
    required this.date,
    required this.fileNameList,
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
    getNumberFileUnread();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getNickname();
    });
    super.initState();
  }

  Future<void> getNickname() async {
    final String result =
        await CommonUtilityFunctions().getNickname(widget.sender ?? '');
    nickname = result;
  }

  void getNumberFileUnread() async {
    int result = 0;
    for (String i in widget.fileNameList) {
      final filePath = widget.type == HistoryType.received
          ? await MixedConstants.getFileDownloadLocation(
              sharedBy: widget.sender)
          : await MixedConstants.getFileSentLocation();
      if (!(await File(filePath + Platform.pathSeparator + i).exists())) {
        result++;
      }
    }
    setState(() {
      numberOfUnreadFile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.type == HistoryType.received
        ? nickname.isNotEmpty
            ? nickname
            : widget.sender ?? ''
        : widget.groupName ?? '${widget.sharedWith.length} Contacts';

    final String subTitle = widget.type == HistoryType.received
        ? widget.sender ?? ''
        : widget.sharedWith
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
                          style: CustomTextStyles.blackW60012,
                        ),
                        if (nickname.isNotEmpty ||
                            widget.type != HistoryType.received)
                          Text(
                            subTitle,
                            style: CustomTextStyles.blackW40010,
                          ),
                      ],
                    ),
                  ),
                  if (trustedContactProvider.trustedContacts
                          .any((element) => element.atSign == widget.sender) ||
                      (widget.sharedWith.length == 1 &&
                          trustedContactProvider.trustedContacts.any(
                              (element) =>
                                  element.atSign ==
                                  widget.sharedWith.single.atsign))) ...[
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
                  DateFormat(MixedConstants.isToday(widget.date)
                          ? 'HH:mm'
                          : 'dd/MM/yyyy HH:mm')
                      .format(widget.date),
                  style: CustomTextStyles.raisinBlackW40010,
                ),
                SizedBox(height: 4),
                if (!isOpenRetryCard)
                  HistoryStatusBadges(
                    type: widget.type,
                    fileNameList: widget.fileNameList,
                    sender: widget.sender,
                    shareWith: widget.sharedWith,
                    numberUnreadFile: numberOfUnreadFile,
                    onOpenRetryCard: () {
                      setState(() {
                        isOpenRetryCard = true;
                      });
                    },
                  ),
              ],
            )
          ],
        ),
        if (widget.note.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            '"${widget.note}"',
            style: CustomTextStyles.raisinBlackW4009,
          )
        ],
        if (isOpenRetryCard) ...[
          SizedBox(height: 4),
          HistoryRetryCard(
            sharedWith: widget.sharedWith,
            onCancelRetryCard: () {
              setState(() {
                isOpenRetryCard = false;
              });
            },
          ),
        ],
      ],
    );
  }
}
