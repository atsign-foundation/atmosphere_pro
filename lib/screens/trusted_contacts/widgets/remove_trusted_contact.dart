import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_outlined_button.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class RemoveConfirmation extends StatelessWidget {
  const RemoveConfirmation({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Map<String, String> user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.toHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),

        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 24,
            spreadRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        // color: Colors.green,
        borderRadius: BorderRadius.circular(10.toWidth),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.toHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Are you sure that you want to',
              style: CustomTextStyles.interSemiBold,
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            Text(
              'Remove',
              style: CustomTextStyles.interBold.copyWith(
                fontSize: 16.toFont,
              ),
            ),
            SizedBox(
              height: 11.toHeight,
            ),
            Text(
              '${user['atSign']}',
              style: CustomTextStyles.interRegular,
            ),
            SizedBox(
              height: 16.toHeight,
            ),
            CustomOutlinedButton(
                height: 28.toHeight,
                width: 115.toWidth,
                radius: 10.toWidth,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm',
                      style: CustomTextStyles.interBold.copyWith(
                        fontSize: 10.toFont,
                        color: ColorConstants.outlineGrey,
                      ),
                    ),
                    SizedBox(
                      width: 10.toWidth,
                    ),
                    Container(
                      height: 18.33.toHeight,
                      width: 18.33.toWidth,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.black,
                          size: 12.toWidth,
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 18.toHeight,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: CustomTextStyles.interRegular.copyWith(
                  fontSize: 10.toFont,
                  decoration: TextDecoration.underline,
                  color: Color(0xFFA4A4A5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
