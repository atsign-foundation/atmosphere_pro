import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupsMemberItemWidget extends StatelessWidget {
  final AtContact member;
  final bool isTrusted;
  final bool isSelected;
  final Function()? onTap;

  const GroupsMemberItemWidget({
    required this.member,
    required this.isTrusted,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: ColorConstants.orange,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            member.tags?['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      Uint8List.fromList(member.tags?['image'].cast<int>()),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : ContactInitial(
                    initials: member.atSign?.substring(1),
                    borderRadius: 18,
                  ),
            SizedBox(width: 16),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.atSign ?? '',
                  style: CustomTextStyles.blackW60013,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.tags?['nickname'] != null)
                  Text(
                    member.tags?['nickname'],
                    style: CustomTextStyles.blackW60013,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            )),
            SizedBox(width: 16),
            SizedBox(
              width: 28,
              height: 28,
              child: SvgPicture.asset(
                isTrusted
                    ? AppVectors.icTrustActivated
                    : AppVectors.icTrustDeactivated,
                width: 24,
                height: 20,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
