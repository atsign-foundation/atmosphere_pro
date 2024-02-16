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
  final FileHistory fileHistory;

  const DesktopHistoryCardHeader({
    required this.fileHistory,
  });

  @override
  State<DesktopHistoryCardHeader> createState() =>
      _DesktopHistoryCardHeaderState();
}

class _DesktopHistoryCardHeaderState extends State<DesktopHistoryCardHeader> {
  String nickname = '';
  late TrustedContactProvider trustedContactProvider;

  @override
  void initState() {
    getNickname();
    trustedContactProvider = context.read<TrustedContactProvider>();
    super.initState();
  }

  void getNickname() async {
    final String result = await CommonUtilityFunctions().getNickname(
      widget.fileHistory.type == HistoryType.received
          ? widget.fileHistory.fileDetails?.sender ?? ''
          : widget.fileHistory.sharedWith?.length == 1
              ? widget.fileHistory.sharedWith?.single.atsign ?? ''
              : '',
    );
    if (mounted) {
      setState(() {
        nickname = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = nickname.isNotEmpty
        ? nickname
        : widget.fileHistory.type == HistoryType.received
            ? widget.fileHistory.fileDetails?.sender ?? ''
            : widget.fileHistory.sharedWith?.length == 1
                ? widget.fileHistory.sharedWith?.single.atsign ?? ''
                : '${widget.fileHistory.sharedWith?.length} Contacts';

    final String subTitle = widget.fileHistory.type == HistoryType.received
        ? widget.fileHistory.fileDetails?.sender ?? ''
        : widget.fileHistory.sharedWith?.length == 1
            ? widget.fileHistory.sharedWith?.single.atsign ?? ''
            : widget.fileHistory.sharedWith!
                .map((shareStatus) => shareStatus.atsign)
                .join(", ")
                .toString();

    return Padding(
      padding: widget.fileHistory.type == HistoryType.received
          ? EdgeInsets.only(left: 12, right: 12, top: 12)
          : EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
                        (widget.fileHistory.type != HistoryType.received &&
                            widget.fileHistory.sharedWith?.length != 1))
                      Text(
                        subTitle,
                        style: CustomTextStyles.blackW40010,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              if (trustedContactProvider.trustedContacts.any((element) =>
                      element.atSign ==
                      widget.fileHistory.fileDetails?.sender) ||
                  (widget.fileHistory.sharedWith?.length == 1 &&
                      trustedContactProvider.trustedContacts.any((element) =>
                          element.atSign ==
                          widget.fileHistory.sharedWith?.single.atsign)))
                SvgPicture.asset(
                  AppVectors.icTrust,
                  color: ColorConstants.portlandOrange,
                )
            ],
          ),
          SizedBox(width: 20),
          (widget.fileHistory.fileDetails?.notes ?? '').isNotEmpty
              ? Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        '"${widget.fileHistory.fileDetails?.notes}"',
                        style: CustomTextStyles.raisinBlackW40010,
                      ),
                    ),
                  ),
                )
              : Spacer(),
          SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat(
                  MixedConstants.isToday(widget.fileHistory.fileDetails!.date!)
                      ? 'HH:mm'
                      : 'dd/MM/yyyy HH:mm',
                ).format(widget.fileHistory.fileDetails!.date!),
                style: CustomTextStyles.raisinBlackW40010,
              ),
              if (widget.fileHistory.type == HistoryType.send) ...[
                SizedBox(height: 4),
                DesktopHistoryStatusBadges(
                  fileHistory: widget.fileHistory,
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}
