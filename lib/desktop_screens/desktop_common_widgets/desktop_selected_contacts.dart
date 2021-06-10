import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_vertical_tile.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSelectedContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: TextSpan(
          text: 'Selected person',
          style: CustomTextStyles.desktopPrimaryBold18,
          children: [
            TextSpan(
              text: '  18 people selected',
              style: CustomTextStyles.desktopSecondaryRegular18,
            )
          ],
        ),
      ),
      SizedBox(
        height: 30,
      ),
      Align(
        alignment: Alignment.center,
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          runSpacing: 10.0,
          spacing: 30.0,
          children: List.generate(20, (index) {
            return customPersonVerticalTile(
              'Levina',
              '@levina',
            );
          }),
        ),
      ),
    ]);
  }
}
