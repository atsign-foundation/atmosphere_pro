import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryStatusBadges extends StatefulWidget {
  final HistoryType? type;
  final List<String> fileNameList;
  final List<ShareStatus>? shareWith;
  final Function() onOpenRetryCard;

  const HistoryStatusBadges({
    Key? key,
    required this.type,
    required this.fileNameList,
    required this.shareWith,
    required this.onOpenRetryCard,
  });

  @override
  State<HistoryStatusBadges> createState() => _HistoryStatusBadgesState();
}

class _HistoryStatusBadgesState extends State<HistoryStatusBadges> {
  int get numberFileUnread {
    int result = 0;
    for (String i in widget.fileNameList) {
      final filePath = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          i;
      if (!(File(filePath).existsSync())) {
        result++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, value, child) {
        if (numberFileUnread != 0) {
          if (widget.type == HistoryType.received) {
            return buildUnreadBadge();
          } else {
            if (widget.shareWith!
                .every((element) => element.isNotificationSend ?? false)) {
              return buildDeliveredBadge();
            } else {
              return buildErrorBadges();
            }
          }
        } else {
          return buildReadAllBadges();
        }
      },
    );
  }

  Widget buildDeliveredBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(49.5),
        color: ColorConstants.deliveredBackgroundColor,
      ),
      child: Text(
        'Delivered',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: ColorConstants.deliveredColor,
        ),
      ),
    );
  }

  Widget buildUnreadBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(49.5),
        color: ColorConstants.unreadBackgroundColor,
        border: Border.all(color: ColorConstants.textGreen),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: numberFileUnread.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: ColorConstants.textGreen,
            ),
          ),
          TextSpan(
            text: ' Unread',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: ColorConstants.textGreen,
            ),
          )
        ]),
      ),
    );
  }

  Widget buildReadAllBadges() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.lightGreen,
          ),
          child: Center(
            child: Icon(
              Icons.done_all,
              size: 20,
              color: ColorConstants.textGreen,
            ),
          ),
        ),
        SizedBox(width: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(49.5),
            color: ColorConstants.lightGreen,
          ),
          child: Text(
            'Read',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildErrorBadges() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.errorBackgroundColor,
          ),
          child: Center(
            child: Text(
              '!',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: ColorConstants.orangeColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(49.5),
            color: ColorConstants.errorBackgroundColor,
          ),
          child: Text(
            'Error',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ColorConstants.orangeColor,
            ),
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: widget.onOpenRetryCard,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(49.5),
              color: ColorConstants.retryButtonColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.iconHeaderColor,
                  ),
                ),
                SizedBox(width: 4),
                SvgPicture.asset(
                  AppVectors.icRefresh,
                  width: 8,
                  height: 8,
                  color: ColorConstants.iconHeaderColor,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
