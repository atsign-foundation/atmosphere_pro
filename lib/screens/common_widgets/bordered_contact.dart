import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'dart:math';

class BorderedContact extends StatelessWidget {
  final AtContact contact;
  final double size;
  final bool nonAsset;
  final TransferStatus transferStatus;

  const BorderedContact({
    Key key,
    this.contact,
    this.size = 40,
    this.nonAsset = true,
    this.transferStatus = TransferStatus.PENDING,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Random r = Random();
    return CircleAvatar(
      radius: 25.toFont,
      backgroundColor: transferStatus == TransferStatus.DONE
          ? Colors.green
          : transferStatus == TransferStatus.PENDING
              ? Colors.orange
              : Colors.red,
      child: contact.tags['image'] != null
          ? Container(
              height: size.toFont,
              width: size.toFont,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.toWidth),
              ),
              child: CircleAvatar(
                radius: (size - 5).toFont,
                backgroundColor: Colors.transparent,
                backgroundImage: Image.memory(contact.tags['image']).image,
              ),
            )
          : Container(
              height: size.toFont,
              width: size.toFont,
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, r.nextInt(255), r.nextInt(255), r.nextInt(255)),
                borderRadius: BorderRadius.circular(size.toWidth),
              ),
              child: Center(
                child: Text(
                  contact.atSign.substring(1, 3).toUpperCase(),
                  style: CustomTextStyles.whiteBold16,
                ),
              ),
            ),
    );
  }
}
