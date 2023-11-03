import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopHistoryRetryContactItem extends StatefulWidget {
  final ShareStatus data;

  const DesktopHistoryRetryContactItem({required this.data});

  @override
  State<DesktopHistoryRetryContactItem> createState() =>
      _DesktopHistoryRetryContactItemState();
}

class _DesktopHistoryRetryContactItemState
    extends State<DesktopHistoryRetryContactItem> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Flexible(
            child: buildHeaderItem(widget.data.atsign ?? ''),
          ),
          SizedBox(width: 4),
          isLoading
              ? CircularProgressIndicator(
                  color: ColorConstants.orangeColor,
                  backgroundColor: ColorConstants.retryBackgroundColor,
                )
              : widget.data.isNotificationSend ?? false
                  ? buildDeliveredBadge()
                  : buildRetryButton(widget.data.atsign ?? ''),
        ],
      ),
    );
  }

  Widget buildHeaderItem(String atSign) {
    return FutureBuilder<String>(
      future: CommonUtilityFunctions().getNickname(atSign),
      builder: (context, snapshot) {
        return Row(
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (snapshot.hasData && (snapshot.data ?? '').isNotEmpty)
                        ? snapshot.data!
                        : atSign,
                    style: CustomTextStyles.blackW60012,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((snapshot.data ?? '').isNotEmpty)
                    Text(
                      atSign,
                      style: CustomTextStyles.blackW40010,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 12),
            if (Provider.of<TrustedContactProvider>(context, listen: false)
                .trustedContacts
                .any((element) => element.atSign == atSign))
              SvgPicture.asset(
                AppVectors.icTrust,
                color: ColorConstants.portlandOrange,
                width: 20,
                height: 20,
              )
          ],
        );
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorConstants.deliveredColor,
        ),
      ),
    );
  }

  Widget buildRetryButton(String atSign) {
    return InkWell(
      onTap: () async {
        await handleResendFileNotification(atSign);
      },
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
    );
  }

  Future<void> handleResendFileNotification(String atSign) async {
    setState(() {
      isLoading = true;
    });
    FileHistory? selectedFileHistory =
        Provider.of<FileTransferProvider>(context, listen: false)
            .getSelectedFileHistory;
    print(
      'selectedFileHistory : ${selectedFileHistory?.fileTransferObject?.transferId}, atsign: $atSign',
    );

    // checking for unUploaded files
    bool isAnyFileUploaded = (selectedFileHistory?.fileDetails?.files ?? [])
        .any((element) => element.isUploaded == true);

    if (isAnyFileUploaded) {
      await Provider.of<FileTransferProvider>(context, listen: false)
          .reSendFileNotification(selectedFileHistory!, atSign);
    } else {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        'Please upload file first.',
      );
    }
    setState(() {
      isLoading = false;
    });
  }
}
