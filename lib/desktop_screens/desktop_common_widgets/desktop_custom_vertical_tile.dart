import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

Widget customPersonVerticalTile(
    String title, String? subTitle, Function onCancel) {
  // if file is being uploaded.
  bool isCancelIcon = !Provider.of<FileTransferProvider>(
          NavService.navKey.currentContext!,
          listen: false)
      .isFileSending;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      InkWell(
        onTap: () {},
        child: Stack(
          children: [
            ContactInitial(
              initials: title,
              size: 50,
              maxSize: (80.0 - 30.0),
              minSize: 50,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  onCancel();
                },
                child: isCancelIcon ? Icon(Icons.cancel) : SizedBox(),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10.toHeight),
      Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: CustomTextStyles.desktopPrimaryRegular14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5.toHeight),
            subTitle != null
                ? Text(
                    subTitle,
                    style: CustomTextStyles.secondaryRegular12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : SizedBox(),
          ],
        ),
      )
    ],
  );
}
