import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/dektop_custom_person_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_input_field.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/widgets/remove_trusted_contact_dialog.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

class DesktopTrustedSender extends StatefulWidget {
  @override
  _DesktopTrustedSenderState createState() => _DesktopTrustedSenderState();
}

class _DesktopTrustedSenderState extends State<DesktopTrustedSender> {
  bool _isFilterOption = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.all(20),
      color: ColorConstants.fadedBlue,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                DesktopHeader(
                  title: 'Trusted Senders',
                  isTitleCentered: true,
                  onFilter: (val) {},
                  actions: [
                    DesktopCustomInputField(
                      backgroundColor: Colors.white,
                      hintText: 'Search...',
                      icon: Icons.search,
                      height: 45,
                      iconColor: ColorConstants.greyText,
                    ),
                    SizedBox(width: 15),
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return ColorConstants.orangeColor;
                        },
                      ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                        (Set<MaterialState> states) {
                          return Size(100, 40);
                        },
                      )),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isFilterOption = !_isFilterOption;
                        });
                      },
                      child: Container(
                        child: Icon(Icons.filter_list_sharp),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Recents',
                  style: CustomTextStyles.blackBold(size: 17),
                ),
                underline(),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
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
                              TextStrings().removeTrustedSender,
                              contact: AtContact(atSign: '@levina'),
                            ),
                          );
                        },
                        child: DesktopCustomPersonVerticalTile(
                            title: 'Levina',
                            subTitle: '@levina',
                            showCancelIcon: false),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'All members',
                  style: CustomTextStyles.blackBold(size: 17),
                ),
                underline(width: 110),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 30.0,
                    children: List.generate(40, (index) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => RemoveTrustedContact(
                              TextStrings().removeTrustedSender,
                              contact: AtContact(atSign: '@levina'),
                            ),
                          );
                        },
                        child: DesktopCustomPersonVerticalTile(
                            title: 'Levina',
                            subTitle: '@levina',
                            showCancelIcon: false),
                      );
                    }),
                  ),
                ),
              ],
            ),
            _isFilterOption
                ? Positioned(
                    right: 15,
                    top: 55,
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.only(
                          right: 10, left: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: ColorConstants.light_grey, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sort by',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isFilterOption = !_isFilterOption;
                                  });
                                },
                                child: Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                          Divider(
                            height: 10,
                            color: ColorConstants.greyText,
                          ),
                          getFilterOptionWidget('By name', true),
                          getFilterOptionWidget('By date', false),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {},
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return ColorConstants.orangeColor;
                              },
                            ), fixedSize:
                                MaterialStateProperty.resolveWith<Size>(
                              (Set<MaterialState> states) {
                                return Size(120, 40);
                              },
                            )),
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget underline({double height = 2, double width = 70}) {
    return Container(
      height: height,
      width: width,
      color: Colors.black,
    );
  }

  Widget getFilterOptionWidget(String title, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) {},
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}
