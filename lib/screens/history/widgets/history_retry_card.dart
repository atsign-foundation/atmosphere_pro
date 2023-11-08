import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_retry_contact_list.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryRetryCard extends StatelessWidget {
  final List<ShareStatus> sharedWith;
  final Function() onCancelRetryCard;

  const HistoryRetryCard({
    required this.sharedWith,
    required this.onCancelRetryCard,
  });

  int get getFailedNumber {
    int result = 0;
    for (var i in sharedWith) {
      if (!(i.isNotificationSend ?? false)) {
        result++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorConstants.retryBackgroundColor,
      ),
      child: Column(
        children: [
          buildHeader(),
          HistoryRetryContactList(
            sharedWith: sharedWith,
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Failed to send to ',
                  style: TextStyle(
                    color: ColorConstants.orangeColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: '\n${getFailedNumber}/${sharedWith.length}',
                  style: TextStyle(
                    color: ColorConstants.orangeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: ' contacts',
                  style: TextStyle(
                    color: ColorConstants.orangeColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          buildErrorBadges(),
        ],
      ),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorConstants.orangeColor,
            ),
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: onCancelRetryCard,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(49.5),
              color: ColorConstants.retryButtonColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.iconHeaderColor,
                  ),
                ),
                SizedBox(width: 4),
                SvgPicture.asset(
                  AppVectors.icCancel,
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
}
