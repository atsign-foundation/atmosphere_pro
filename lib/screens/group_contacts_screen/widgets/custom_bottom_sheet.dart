import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CustomBottomSheet extends StatelessWidget {
  final List<AtContact> list;
  final Function onPressed;
  const CustomBottomSheet({Key key, this.list, this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return (list.isEmpty)
        ? Container(
            height: 0,
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
            height: 70.toHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    (list.length != 25)
                        ? '${list.length} Contacts Selected'
                        : '25 of 25 Contact Selected',
                    style: CustomTextStyles.primaryMedium14,
                  ),
                ),
                CustomButton(
                  buttonText: 'Done',
                  width: 120.toWidth,
                  height: 40.toHeight,
                  isOrange: true,
                  onPressed: onPressed,
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Color(0xffF7F7FF),
                boxShadow: [BoxShadow(color: Colors.grey)]),
          );
  }
}
