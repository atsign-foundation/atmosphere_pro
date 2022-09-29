import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

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
      color: Color(0xFFF1F1F1),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFF939393),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              image,
              height: 27,
              width: 27,
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              buttonText.toString(),
              style: CustomTextStyles.greySemiBold18,
            ),
          ],
        ),
      ),
    );
  }
}
