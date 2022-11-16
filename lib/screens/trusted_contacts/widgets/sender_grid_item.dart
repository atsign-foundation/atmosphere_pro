import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SenderGridItem extends StatelessWidget {
  const SenderGridItem({
    Key? key,
    required this.atContact,
  }) : super(key: key);
  final AtContact atContact;
  // final Map<String, String> user;
  Uint8List? get byteImage =>
      CommonUtilityFunctions().getCachedContactImage(atContact.atSign!);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.textBoxBg,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.toWidth),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.toHeight,
          // horizontal: 5.toWidth,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 5.toWidth,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 39.toHeight,
                  width: 39.toWidth,
                  child: byteImage == null
                      ? CircleAvatar(
                          backgroundColor: ColorConstants.textBoxBg,
                          child: Text(
                            atContact.atSign!.substring(1, 3).toUpperCase(),
                            style: CustomTextStyles.redSmall12,
                          ),
                        )
                      : SizedBox(),
                  decoration: byteImage != null
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: MemoryImage(byteImage!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: -9,
                  left: -5,
                  child: Image.asset(
                    ImageConstants.verified,
                    height: 24.toHeight,
                    width: 24.toWidth,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 7.toWidth,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atContact.atSign!,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.interSemiBold.copyWith(
                    color: Colors.black,
                  ),
                ),
                atContact.tags != null && atContact.tags!['nickname'] != null
                    ? Text(
                        '${atContact.tags!['nickname']}',
                        style: CustomTextStyles.interRegular.copyWith(
                          fontSize: 8.toFont,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
