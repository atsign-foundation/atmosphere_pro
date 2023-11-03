import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_status_badges.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DesktopHistoryCardHeader extends StatefulWidget {
  final HistoryType? type;
  final String? sender;
  final String? groupName;
  final List<ShareStatus> sharedWith;
  final String note;
  final DateTime date;
  final List<String> fileNameList;
  final bool isHideBadges;
  final Function() onOpenRetryCard;

  const DesktopHistoryCardHeader({
    required this.type,
    required this.sender,
    required this.groupName,
    required this.sharedWith,
    required this.note,
    required this.date,
    required this.fileNameList,
    required this.isHideBadges,
    required this.onOpenRetryCard,
  });

  @override
  State<DesktopHistoryCardHeader> createState() =>
      _DesktopHistoryCardHeaderState();
}

class _DesktopHistoryCardHeaderState extends State<DesktopHistoryCardHeader> {
  String nickname = '';
  int numberOfUnreadFile = 0;
  late TrustedContactProvider trustedContactProvider;

  @override
  void initState() {
    getNickname();
    trustedContactProvider = context.read<TrustedContactProvider>();
    getNumberFileUnread();
    super.initState();
  }

  void getNickname() async {
    final String result = await CommonUtilityFunctions()
        .getNickname(widget.type == HistoryType.received
            ? widget.sender ?? ''
            : widget.sharedWith.length == 1
                ? widget.sharedWith.single.atsign ?? ''
                : '');
    if (mounted) {
      setState(() {
        nickname = result;
      });
    }
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
    if (mounted) {
      setState(() {
        numberOfUnreadFile = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = nickname.isNotEmpty
        ? nickname
        : widget.type == HistoryType.received
            ? widget.sender ?? ''
            : widget.sharedWith.length == 1
                ? widget.sharedWith.single.atsign ?? ''
                : '${widget.sharedWith.length} Contacts';

    final String subTitle = widget.type == HistoryType.received
        ? widget.sender ?? ''
        : widget.sharedWith.length == 1
            ? widget.sharedWith.single.atsign ?? ''
            : widget.sharedWith
                .map((shareStatus) => shareStatus.atsign)
                .join(", ")
                .toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyles.blackW60012,
                  ),
                  if (nickname.isNotEmpty ||
                      (widget.type != HistoryType.received &&
                          widget.sharedWith.length != 1))
                    Text(
                      subTitle,
                      style: CustomTextStyles.blackW40010,
                    ),
                ],
              ),
            ),
            SizedBox(width: 12),
            if (trustedContactProvider.trustedContacts
                    .any((element) => element.atSign == widget.sender) ||
                (widget.sharedWith.length == 1 &&
                    trustedContactProvider.trustedContacts.any((element) =>
                        element.atSign == widget.sharedWith.single.atsign)))
              SvgPicture.asset(
                AppVectors.icTrust,
                color: ColorConstants.portlandOrange,
              )
          ]),
          SizedBox(width: 20),
          widget.note.isNotEmpty
              ? Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        '"${widget.note}"',
                        style: CustomTextStyles.raisinBlackW40010,
                      ),
                    ),
                  ),
                )
              : Spacer(),
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
              if (!widget.isHideBadges)
                DesktopHistoryStatusBadges(
                  type: widget.type,
                  fileNameList: widget.fileNameList,
                  sender: widget.sender,
                  shareWith: widget.sharedWith,
                  numberUnreadFile: numberOfUnreadFile,
                  onOpenRetryCard: widget.onOpenRetryCard,
                ),
            ],
          )
        ],
      ),
    );
  }
}
