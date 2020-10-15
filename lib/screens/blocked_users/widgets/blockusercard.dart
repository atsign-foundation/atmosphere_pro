import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';

class BlockedUserCard extends StatefulWidget {
  final Map<String, dynamic> blockeduser;

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
              widget.blockeduser['name'].toString(),
              style: CustomTextStyles.primaryRegular16,
            ),
            Text(
              widget.blockeduser['handle'].toString(),
              style: CustomTextStyles.secondaryRegular12,
            ),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: () {},
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
