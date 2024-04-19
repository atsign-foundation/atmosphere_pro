import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_status_badges.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorySentCardHeader extends StatefulWidget {
  final FileHistory fileHistory;

  const HistorySentCardHeader({
    required this.fileHistory,
  });

  @override
  State<HistorySentCardHeader> createState() => _HistorySentCardHeaderState();
}

class _HistorySentCardHeaderState extends State<HistorySentCardHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HistoryStatusBadges(
          fileHistory: widget.fileHistory,
        ),
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
      ],
    );
  }
}
