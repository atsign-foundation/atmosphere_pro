import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedUserCard extends StatefulWidget {
  final AtContact blockeduser;

  const BlockedUserCard({Key key, this.blockeduser}) : super(key: key);
  @override
  _BlockedUserCardState createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends State<BlockedUserCard> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomCircleAvatar(
        image: ImageConstants.test,
      ),
      title: Container(
        width: 300.toWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.blockeduser.atSign.substring(1).toString(),
              style: CustomTextStyles.primaryRegular16,
            ),
            Text(
              widget.blockeduser.atSign.toString(),
              style: CustomTextStyles.secondaryRegular12,
            ),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: () {
          Provider.of<ContactProvider>(context, listen: false)
              .blockUnBLockContact(
                  atSign: widget.blockeduser.atSign, blockAction: false);
        },
        child: Container(
          child: Text(
            'Unblock',
            style: CustomTextStyles.blueRegular14,
          ),
        ),
      ),
    );
  }
}
