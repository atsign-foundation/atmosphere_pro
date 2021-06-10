import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_group/desktop_new_group.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopEmptyGroup extends StatefulWidget {
  @override
  _DesktopEmptyGroupState createState() => _DesktopEmptyGroupState();
}

class _DesktopEmptyGroupState extends State<DesktopEmptyGroup> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig().screenWidth,
      child: Row(
        children: [
          Container(
            width: SizeConfig().screenWidth / 2 - 35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AllImages().EMPTY_GROUP,
                  width: 181.toWidth,
                  height: 181.toWidth,
                  fit: BoxFit.cover,
                  package: 'at_contacts_group_flutter',
                ),
                SizedBox(
                  height: 15.toHeight,
                ),
                Text('No Groups!', style: CustomTextStyles.greyText16),
                SizedBox(
                  height: 5.toHeight,
                ),
                Text(
                  'Would you like to create a group?',
                  style: CustomTextStyles.greyText16,
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return ColorConstants.orangeColor;
                    },
                  ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                    (Set<MaterialState> states) {
                      return Size(160, 45);
                    },
                  )),
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: SizeConfig().screenWidth / 2 - 35,
            child: DesktopNewGroup(),
          )
        ],
      ),
    );
  }
}
