import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          ImageConstants.logoIcon,
          height: 72.toWidth,
          width: 56.toHeight,
        ),
        SizedBox(width: 8.toWidth),
        RichText(
          text: TextSpan(
            text: 'Atmosphere',
            style: TextStyle(
              fontSize: 35.toFont,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'Pro',
                style: TextStyle(
                  fontSize: 35.toFont,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
