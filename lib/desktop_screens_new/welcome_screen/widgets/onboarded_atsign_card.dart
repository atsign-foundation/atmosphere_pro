import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardedAtSignCard extends StatelessWidget {
  final Uint8List? avatar;
  final String? displayName;
  final String atSignKey;
  final bool isExpanded;
  final bool isSelected;
  final Function() onTap;

  const OnboardedAtSignCard({
    required this.avatar,
    required this.displayName,
    required this.atSignKey,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: isExpanded
          ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
          : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
      color: ColorConstants.unselectedFilterOptionBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        isExpanded ? 20 : 0,
        16,
        isExpanded ? 24 : 0,
        16,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: avatar != null
                ? Image.memory(
                    avatar!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : ContactInitial(
                    initials: atSignKey.replaceFirst('@', ''),
                    size: 48,
                    borderRadius: 10,
                  ),
          ),
          if (isExpanded) ...[
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((displayName ?? '').isNotEmpty)
                    Text(
                      displayName!,
                      style: CustomTextStyles.desktopPrimaryW50010,
                    ),
                  Text(
                    atSignKey,
                    style: CustomTextStyles.desktopPrimaryW50015,
                  ),
                ],
              ),
            ),
          ] else
            SizedBox(width: 20),
          InkWell(
            onTap: onTap,
            child: SvgPicture.asset(
              AppVectors.icMore,
              width: 20,
              height: 20,
              color: isSelected
                  ? ColorConstants.raisinBlack
                  : ColorConstants.disableIconButton,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
