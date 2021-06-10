import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopContactsScreen extends StatelessWidget {
  final bool isBlockedScreen;
  DesktopContactsScreen({Key key, this.isBlockedScreen = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.inputFieldColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    DesktopSetupRoutes.nested_pop();
                  },
                  child: Icon(Icons.arrow_back, size: 25, color: Colors.black),
                ),
                SizedBox(
                  width: 30,
                ),
                Text(
                  'All Contacts',
                  style: CustomTextStyles.desktopPrimaryRegular24,
                ),
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: TextField(
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
                ),
                SizedBox(
                  width: 30,
                ),
                CommonButton(
                  'Add Contact',
                  () {},
                  leading: Icon(Icons.add, size: 25, color: Colors.white),
                  color: ColorConstants.orangeColor,
                  border: 3,
                  height: 45,
                  width: 170,
                  fontSize: 18,
                  removePadding: true,
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return contacts_tile();
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 0.2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contacts_tile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          ContactInitial(
            initials: 'Levina',
            maxSize: 50,
            minSize: 50,
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            'A Thomas',
            style: CustomTextStyles.primaryNormal20,
          ),
          SizedBox(
            width: 200,
          ),
          Text('@levinat', style: CustomTextStyles.desktopSecondaryRegular18),
          Spacer(),
          isBlockedScreen ? _forBlockScreen() : _forContactsScreen(),
          SizedBox(
            width: 50,
          ),
        ],
      ),
    );
  }

  Widget _forContactsScreen() {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: ColorConstants.orangeColor,
        ),
        SizedBox(
          width: 50,
        ),
        Image.asset(
          AllImages().SEND,
          width: 21.toWidth,
          height: 18.toHeight,
        ),
      ],
    );
  }

  Widget _forBlockScreen() {
    return Text(
      'Unblock',
      style: CustomTextStyles.blueNormal20,
    );
  }
}
