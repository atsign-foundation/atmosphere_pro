import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardExpanded extends StatefulWidget {
  final AtContact atContact;

  const CardExpanded(this.atContact);

  @override
  State<CardExpanded> createState() => _CardExpandedState();
}

class _CardExpandedState extends State<CardExpanded> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          children: [],
        ),
      ),
    );
  }

  Widget buildAppBarRow() {
    return Row();
  }

  Widget buildInfoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.atContact.tags?['image'] != null
            ? CustomCircleAvatar(
                byteImage: Uint8List.fromList(
                    widget.atContact.tags!['image'].cast<int>()),
                nonAsset: true,
                size: 72,
              )
            : ContactInitial(
                initials: widget.atContact.atSign,
                size: 72,
              ),
        SizedBox(height: 4),
        Text(
          widget.atContact.tags?['nickname'] ??
              widget.atContact.atSign?.substring(1),
          style: CustomTextStyles.desktopPrimaryRegular18,
        ),
        Text(
          widget.atContact.atSign ?? '',
          style: CustomTextStyles.desktopPrimaryRegular14,
        )
      ],
    );
  }
}
