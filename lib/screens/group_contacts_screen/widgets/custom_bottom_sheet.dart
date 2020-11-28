import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

// class BottomSheet extends StatefulWidget {
//   @override
//   _BottomSheetState createState() => _BottomSheetState();
// }

class CustomBottomSheet extends StatelessWidget {
  final int numberOfContacts;

  const CustomBottomSheet({Key key, this.numberOfContacts}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
      height: 70.toHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              (numberOfContacts != 25)
                  ? '$numberOfContacts Contacts Selected'
                  : '25 of 25 Contact Selected',
              style: CustomTextStyles.primaryMedium14,
            ),
          ),
          CustomButton(
            buttonText: 'Done',
            width: 120.toWidth,
            height: 40.toHeight,
            isOrange: true,
          )
        ],
      ),
      decoration: BoxDecoration(
          color: Color(0xffF7F7FF), boxShadow: [BoxShadow(color: Colors.grey)]),
    );
  }
}
