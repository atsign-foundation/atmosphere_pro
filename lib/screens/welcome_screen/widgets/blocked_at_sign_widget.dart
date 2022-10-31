import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class BlockedAtSignWidget extends StatelessWidget {
  const BlockedAtSignWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: 58.toHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorConstants.buttonBorderColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "@airplanes45",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13.toFont,
            ),
          ),
          Container(
              height: 31.toHeight,
              width: 118.toWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ColorConstants.lightGrey),
                color: ColorConstants.buttonBackgroundColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Unblock?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.toFont,
                    ),
                  ),
                  Image.asset(
                    ImageConstants.block,
                    height: 16.toHeight,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
