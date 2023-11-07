import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    required this.image,
  }) : super(key: key);

  final Function()? onPressed;
  final String? buttonText;
  final String image;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      onPressed: onPressed,
      color: ColorConstants.jetColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              image,
              color: ColorConstants.textBoxBg,
              height: 27,
              width: 27,
            ),
            const SizedBox(width: 24),
            Text(
              buttonText.toString(),
              style: CustomTextStyles.whiteMedium18.copyWith(
                color: ColorConstants.textBoxBg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
