import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_card_function_list.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopHistoryStatusBadges extends StatelessWidget {
  final FileHistory fileHistory;

  const DesktopHistoryStatusBadges({
    required this.fileHistory,
  });

  void openFileReceiptBottomSheet({
    FileRecipientSection? fileRecipientSection,
    required BuildContext context,
  }) {
    Provider.of<FileTransferProvider>(NavService.navKey.currentContext!,
            listen: false)
        .selectedFileHistory = fileHistory;

    showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (_context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                insetPadding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  width: 400,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12.0),
                      topRight: const Radius.circular(12.0),
                    ),
                  ),
                  child: FileRecipients(
                    fileHistory.sharedWith,
                    fileRecipientSection: fileRecipientSection,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (fileHistory.type == HistoryType.received) {
      return DesktopCardFunctionList(fileTransfer: fileHistory.fileDetails!);
    } else {
      return InkWell(
        onTap: () {
          openFileReceiptBottomSheet(context: context);
        },
        child: fileHistory.sharedWith!
                .every((element) => element.isNotificationSend ?? false)
            ? buildDeliveredBadge()
            : buildErrorBadges(),
      );
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
        Container(
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
        )
      ],
    );
  }
}
