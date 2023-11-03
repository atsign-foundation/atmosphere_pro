import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_retry_contact_list.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopHistoryRetryCard extends StatelessWidget {
  final List<ShareStatus> sharedWith;
  final Function() onCancel;

  const DesktopHistoryRetryCard({
    required this.sharedWith,
    required this.onCancel,
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorConstants.retryBackgroundColor,
      ),
      child: Column(
        children: [
          buildHeader(),
          SizedBox(height: 8),
          DesktopHistoryRetryContactList(
            sharedWith: sharedWith,
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
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
                  text: '${getFailedNumber}/${sharedWith.length}',
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
          onTap: onCancel,
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
