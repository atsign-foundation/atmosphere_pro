import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopHistoryStatusBadges extends StatelessWidget {
  final HistoryType? type;
  final List<String> fileNameList;
  final String? sender;
  final List<ShareStatus>? shareWith;
  final int numberUnreadFile;
  final Function() onOpenRetryCard;

  const DesktopHistoryStatusBadges({
    required this.type,
    required this.fileNameList,
    required this.sender,
    required this.shareWith,
    required this.numberUnreadFile,
    required this.onOpenRetryCard,
  });

  @override
  Widget build(BuildContext context) {
    if (numberUnreadFile != 0) {
      if (type == HistoryType.received) {
        return buildUnreadBadge(numberUnreadFile);
      } else {
        if (shareWith!
            .every((element) => element.isNotificationSend ?? false)) {
          return buildDeliveredBadge();
        } else {
          return buildErrorBadges();
        }
      }
    } else {
      return buildReadAllBadges();
    }
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorConstants.deliveredColor,
        ),
      ),
    );
  }

  Widget buildUnreadBadge(int number) {
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
            text: number.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: ColorConstants.textGreen,
            ),
          ),
          TextSpan(
            text: ' Unread',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
              size: 16,
              color: ColorConstants.textGreen,
            ),
          ),
        ),
        SizedBox(width: 4),
        buildTextBadge(
          backgroundColor: ColorConstants.lightGreen,
          color: ColorConstants.textGreen,
          text: 'Read',
        ),
      ],
    );
  }

  Widget buildErrorBadges() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorConstants.orangeColor,
            ),
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: onOpenRetryCard,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.iconHeaderColor,
                  ),
                ),
                SizedBox(width: 4),
                SvgPicture.asset(
                  AppVectors.icRefresh,
                  width: 12,
                  height: 12,
                  color: ColorConstants.iconHeaderColor,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildTextBadge({
    required Color backgroundColor,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(49.5),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
