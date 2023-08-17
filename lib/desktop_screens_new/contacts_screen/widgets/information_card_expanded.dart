import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InformationCardExpanded extends StatefulWidget {
  final AtContact atContact;
  final Function() onBack;

  const InformationCardExpanded({
    required this.atContact,
    required this.onBack,
  });

  @override
  State<InformationCardExpanded> createState() => _InformationCardExpandedState();
}

class _InformationCardExpandedState extends State<InformationCardExpanded> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Column(
            children: [
              buildAppBarRow(),
            ],
          ),

      ),
    );
  }

  Widget buildAppBarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.onBack,
          child: SvgPicture.asset(
            AppVectors.icBack,
            height: 24,
            width: 24,
          ),
        ),
        buildInfoWidget(),
        InkWell(
          child: SvgPicture.asset(
            AppVectors.icMore,
            height: 24,
            width: 20,
          ),
        ),
      ],
    );
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
