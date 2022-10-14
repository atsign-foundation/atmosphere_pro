import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/blocked_at_sign_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

Future<dynamic> blockedAtSignsSheet(BuildContext context) {
  SizeConfig().init(context);
  return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 23, bottom: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45.toWidth,
                        height: 2.toHeight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 106.toWidth,
                        height: 31.toHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: ColorConstants.buttonBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Text(
                            "Close",
                            style: TextStyle(
                              fontSize: 17.toFont,
                              color: ColorConstants.buttonBorderColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  "Blocked atSigns",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25.toFont),
                ),
                SizedBox(height: 30.toHeight),
                Container(
                  height: 95.toHeight,
                  decoration: BoxDecoration(
                    color: ColorConstants.buttonBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Refresh",
                            style: TextStyle(
                              color: ColorConstants.greyTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.toFont,
                            ),
                          ),
                          Container(
                            width: 48.toWidth,
                            height: 48.toWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ColorConstants.buttonBorderColor,
                              ),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Image.asset(
                                ImageConstants.reload,
                                width: 17.toWidth,
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Search",
                            style: TextStyle(
                              color: ColorConstants.greyTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.toFont,
                            ),
                          ),
                          Container(
                            width: 235.toWidth,
                            height: 48.toWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ColorConstants.buttonBorderColor,
                              ),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        decoration: InputDecoration.collapsed(
                                          hintText: "Search History by atSign",
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.search),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 27.toHeight,
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 37.toHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            color: ColorConstants.lightGrey,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0.toWidth,
                                  right: 6.toWidth,
                                ),
                                child: Text(
                                  "atSign",
                                  style: TextStyle(
                                    fontSize: 15.toFont,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.greyTextColor,
                                  ),
                                ),
                              ),
                              Image.asset(
                                ImageConstants.downArrow,
                                width: 11.toWidth,
                              ),
                            ],
                          ),
                        ),
                        BlockedAtSignWidget()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
