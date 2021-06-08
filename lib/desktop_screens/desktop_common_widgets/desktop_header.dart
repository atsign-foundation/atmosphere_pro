import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_input_field.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DdesktopHeader extends StatelessWidget {
  final String title;
  List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  bool showBackIcon;
  DdesktopHeader({this.title, this.showBackIcon = true});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 20),
          showBackIcon
              ? InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back),
                )
              : SizedBox(),
          SizedBox(width: 15),
          title != null
              ? Text(
                  title,
                  style: CustomTextStyles.primaryRegular20,
                )
              : SizedBox(),
          SizedBox(width: 15),
          Expanded(child: SizedBox()),
          DesktopCustomInputField(
            backgroundColor: Colors.white,
            hintText: 'Search...',
            icon: Icons.search,
            height: 45,
            iconColor: ColorConstants.greyText,
          ),
          SizedBox(width: 15),
          InkWell(
              onTap: () {},
              child: Container(
                width: 100,
                child: DropdownButton(
                  icon: Icon(Icons.filter_list_sharp),
                  underline: SizedBox(),
                  isExpanded: true,
                  autofocus: false,
                  value: 'By type',
                  onChanged: (val) {},
                  selectedItemBuilder: (BuildContext context) {
                    return options.map((String value) {
                      return Text(
                        '',
                        style: const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option == 'add-btn' ? null : option,
                      child: option == 'add-btn'
                          ? Text('add button')
                          : Container(
                              width: 300,
                              child: Row(children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(option),
                                ),
                                Checkbox(
                                  value: true,
                                  onChanged: (value) {},
                                  activeColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                )
                              ]),
                            ),
                    );
                  }).toList(),
                ),
              )),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
