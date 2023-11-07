import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopContactTile extends StatelessWidget {
  const DesktopContactTile({
    Key? key,
    required this.title,
    required this.subTitle,
    this.showImage = false,
    this.image,
  }) : super(key: key);

  final String? title, subTitle;
  final bool showImage;
  final Uint8List? image;

  removeTrustedContact(BuildContext context) async {
    var res = await Provider.of<TrustedContactProvider>(context, listen: false)
        .removeTrustedContacts(AtContact(atSign: title));

    if (res == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorConstants.successGreen,
          content: Text(
            'Successfully removed contact from trusted senders',
            style: CustomTextStyles.secondaryRegular14,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorConstants.red,
          content: Text(
            'Failed to remove contact',
            style: CustomTextStyles.secondaryRegular14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          showImage
              ? SizedBox(
                  height: 60,
                  width: 60,
                  child: Image.memory(
                    image!,
                    fit: BoxFit.fill,
                    errorBuilder: (BuildContext context, _, __) {
                      return Icon(
                        Icons.image,
                        size: 30.toFont,
                      );
                    },
                  ),
                )
              : ContactInitial(
                  initials: (title ?? '').replaceFirst('@', ''),
                  size: 60,
                  maxSize: (80.0 - 20.0),
                  minSize: 60,
                  borderRadius: 0,
                ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 10.toHeight),
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              (subTitle ?? '').isNotEmpty
                  ? Text(
                      subTitle!,
                      style: CustomTextStyles.desktopPrimaryRegular12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(),
              SizedBox(width: 10.toHeight),
            ],
          ),
          const Spacer(),
          // Icon(
          //   Icons.send_outlined,
          //   color: Theme.of(context).primaryColor,
          //   size: 24,
          // ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () async {
              await removeTrustedContact(context);
            },
            child: Icon(
              Icons.verified_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // Icon(
          //   Icons.more_horiz_outlined,
          //   color: ColorConstants.MILD_GREY,
          //   size: 24,
          // ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}
