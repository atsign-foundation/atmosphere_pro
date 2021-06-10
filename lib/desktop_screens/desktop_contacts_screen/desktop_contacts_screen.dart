import 'package:at_contacts_flutter/widgets/custom_search_field.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_contacts_custom_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_vertical_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DesktopContactsScreen extends StatefulWidget {
  const DesktopContactsScreen({Key key}) : super(key: key);

  @override
  _DesktopContactsScreenState createState() => _DesktopContactsScreenState();
}

class _DesktopContactsScreenState extends State<DesktopContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.inputFieldColor,
        appBar: AppBar(
          backgroundColor: ColorConstants.inputFieldColor,
          leading: Icon(Icons.arrow_back, size: 25, color: Colors.black),
          title: Text(
            'Select Person',
            style: CustomTextStyles.desktopPrimaryBold18,
          ),
          centerTitle: true,
        ),
        body: Container(
          height: SizeConfig().screenHeight - MixedConstants.APPBAR_HEIGHT,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  _changePreferenceButton('Recent', 70,
                      color: ColorConstants.light_grey,
                      textColor: ColorConstants.fadedText),
                  SizedBox(
                    width: 10,
                  ),
                  _changePreferenceButton('Favourites', 80,
                      color: ColorConstants.light_grey,
                      textColor: ColorConstants.fadedText),
                  SizedBox(
                    width: 10,
                  ),
                  _changePreferenceButton('All Members', 100,
                      color: ColorConstants.orangeColor,
                      textColor: Colors.white),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              // ContactSearchField('Search Contact', (str) {}),

              /// TODO: We have a component for this ContactSearchField, don't recreate
              TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Contact',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.greyText,
                  ),
                  filled: true,
                  fillColor: ColorConstants.scaffoldColor,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search,
                      color: ColorConstants.greyText,
                      size: 35,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.fontPrimary,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              SizedBox(
                height: 130,
                width:
                    (SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH) /
                            2 -
                        40,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  // shrinkWrap: true,
                  itemCount: 19,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 14),
                      child: customPersonVerticalTile('Alexa', '@alexa'),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  // physics: AlwaysScrollableScrollPhysics(),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 14),
                      width: (SizeConfig().screenWidth -
                                  MixedConstants.SIDEBAR_WIDTH) /
                              2 -
                          40,
                      child: DesktopContactsCustomListTile(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '20 Contact Selected',
                  style: CustomTextStyles.primaryRegular20,
                ),
                CommonButton(
                  'Done',
                  () {},
                  color: ColorConstants.orangeColor,
                  border: 3,
                  height: 45,
                  width: 130,
                  fontSize: 20,
                  removePadding: true,
                ),
              ],
            ),
          )
        ]);
  }

  _changePreferenceButton(String text, double width,
      {Function onTap, Color color, Color textColor}) {
    return CommonButton(
      text,
      () {},
      color: color ?? Colors.white,
      border: 20,
      height: 30,
      width: width,
      fontSize: 14,
      removePadding: true,
      textColor: textColor,
    );
  }
}
