import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class SenderGridItem extends StatelessWidget {
  const SenderGridItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Map<String, String> user;

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
        ),
        child: Row(
          children: [
            SizedBox(
              width: 9.toWidth,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 39.toHeight,
                  width: 39.toWidth,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        user['avatar']!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  user['atSign']!,
                  style: CustomTextStyles.interSemiBold.copyWith(
                    color: Colors.black,
                  ),
                ),
                Text(
                  user['name']!,
                  style: CustomTextStyles.interRegular.copyWith(
                    fontSize: 8.toFont,
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
