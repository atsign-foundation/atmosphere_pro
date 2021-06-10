import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_person_vertical_tile.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/widgets/remove_trusted_contact_dialog.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:at_contact/at_contact.dart';

class DesktopGroupDetail extends StatefulWidget {
  @override
  _DesktopGroupDetailState createState() => _DesktopGroupDetailState();
}

class _DesktopGroupDetailState extends State<DesktopGroupDetail> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Image.asset(
                    ImageConstants.welcomeDesktop,
                    height: 272.toHeight,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 30.0,
                    children: List.generate(20, (index) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => RemoveTrustedContact(
                              TextStrings().removeGroupMember,
                              contact: AtContact(atSign: '@kevin'),
                            ),
                          );
                        },
                        child: DesktopCustomPersonVerticalTile(
                          title: 'title',
                          subTitle: '@kevin',
                          isAssetImage: true,
                          atsign: '@levina',
                        ),
                      );
                    }),
                  )
                ],
              ),
              Positioned(
                top: 240.toHeight,
                child: Container(
                  height: 80.toHeight,
                  width: SizeConfig().screenWidth * 0.92,
                  margin: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 0.toHeight),
                  padding: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 10.toHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: ColorConstants.greyText,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 0.0),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 250.toWidth,
                                  child: Text(
                                    'Group name',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    // softWrap: false,
                                    style: TextStyle(
                                      color: ColorConstants.greyText,
                                      fontSize: 16.toFont,
                                    ),
                                  ),
                                ),
                                Text(
                                  '10 members',
                                  style: CustomTextStyles.greyText15,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () async {},
                        child: Icon(
                          Icons.add,
                          size: 30.toFont,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 30.toHeight,
                  left: 10.toWidth,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 25.toFont,
                    ),
                  )),
              Positioned(
                top: 30.toHeight,
                right: 10.toWidth,
                child: InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 25.toFont,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
