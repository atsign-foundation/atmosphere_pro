import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSwitchAtsign extends StatelessWidget {
  DesktopSwitchAtsign({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactRow('Levina Thomas', '@levina', isCurrentAtsign: true),
          Divider(
            thickness: 0.75,
          ),
          Text(
            'Switch @sign',
            style: CustomTextStyles.desktopSecondaryRegular16,
          ),
          SizedBox(
            height: 14,
          ),
          _contactRow('Levine', '@levi01'),
          SizedBox(
            height: 10,
          ),
          _contactRow('Levine', '@levi23'),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: ColorConstants.fadedText,
                  size: 35,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Add',
                style: CustomTextStyles.desktopSecondaryRegular14,
              )
            ],
          ),
        ],
      ),
    );
  }

  _contactRow(String title, String subTitle, {bool isCurrentAtsign = false}) {
    return Row(
      children: <Widget>[
        ContactInitial(
          initials: title ?? ' ',
          size: isCurrentAtsign ? 60 : 40,
          maxSize: isCurrentAtsign ? 60 : 40,
          minSize: isCurrentAtsign ? 60 : 40,
        ),
        SizedBox(width: 10),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: isCurrentAtsign
                    ? CustomTextStyles.blackBold()
                    : CustomTextStyles.desktopSecondaryRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5),
              Text(
                subTitle,
                style: isCurrentAtsign
                    ? CustomTextStyles.greyText16
                    : CustomTextStyles.desktopSecondaryRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }
}
