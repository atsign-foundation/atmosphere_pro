import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/dektop_custom_person_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_group/bottom_sheet.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopNewGroup extends StatefulWidget {
  @override
  _DesktopNewGroupState createState() => _DesktopNewGroupState();
}

class _DesktopNewGroupState extends State<DesktopNewGroup> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstants.listBackground,
        bottomSheet: DesktopGroupBottomSheet(
          onPressed: () {},
          message: '18 Contacts Selected',
          buttontext: 'Done',
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20.toHeight),
            GestureDetector(
              onTap: () async {},
              child: Container(
                margin: EdgeInsets.only(left: 15),
                width: 100.toWidth,
                height: 100.toWidth,
                decoration: BoxDecoration(
                  color: ColorConstants.dividerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: false
                      ? SizedBox(
                          width: 68.toWidth,
                          height: 68.toWidth,
                          // child: CircleAvatar(
                          //   backgroundImage:
                          //       Image.memory().image,
                          // ),
                        )
                      : SizedBox(),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 15.toWidth,
                ),
                SizedBox(width: 10.toWidth),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Container(
                            width: 330.toWidth,
                            height: 50.toHeight,
                            decoration: BoxDecoration(
                              color: ColorConstants.listBackground,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    readOnly: false,
                                    style: TextStyle(
                                      fontSize: 15.toFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter Group Name',
                                      enabledBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(fontSize: 15.toFont),
                                    ),
                                    onTap: () {},
                                    onChanged: (val) {},
                                    // controller: textController,
                                    onSubmitted: (str) {},
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: Colors.grey,
                                    size: 20.toFont,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 13.toHeight),
            Divider(),
            SizedBox(height: 13.toHeight),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(right: 15, left: 15),
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 50.0,
                    children: List.generate(30, (index) {
                      return DesktopCustomPersonVerticalTile(
                        title: 'Levina',
                        subTitle: '@levina',
                        showCancelIcon: true,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
